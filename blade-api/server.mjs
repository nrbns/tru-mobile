import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import fetch from 'node-fetch';
import admin from 'firebase-admin';

// Initialize Firebase Admin using ADC or env credentials
try {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
} catch (e) {
  console.error('Firebase Admin init error:', e);
}

const app = express();
app.use(express.json({ limit: '1mb' }));
app.use(cors({ origin: true }));
app.set('trust proxy', 1);

const limiter = rateLimit({ windowMs: 60 * 1000, max: 60 });
app.use(limiter);

// Auth middleware: verify Firebase ID token
async function verifyFirebaseToken(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'missing_token' });
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded; // uid, email, etc.
    next();
  } catch (e) {
    return res.status(401).json({ error: 'invalid_token' });
  }
}

app.get('/health', (req, res) => res.json({ ok: true }));

// AI coach endpoint (Gemini/OpenAI; falls back if no key)
app.post('/ai/coach', verifyFirebaseToken, async (req, res) => {
  const { goal, currentWeight, mood, message } = req.body || {};
  const uid = req.user?.uid;
  try {
    const openaiKey = process.env.OPENAI_API_KEY;
    const geminiKey = process.env.GEMINI_API_KEY;
    const useGemini = !openaiKey && geminiKey;
    const context = `User ${uid}\nGoal:${goal || 'fitness'}\nWeight:${currentWeight || 'n/a'}\nMood:${mood || 'n/a'}`;
    const prompt = `${context}\n\nInstruction: ${message || 'Give one concise actionable advice.'}`;

    let content = 'Set daily targets: hydrate, protein with each meal, 20‑min walk.';
    if (openaiKey || geminiKey) {
      if (useGemini) {
        const r = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${geminiKey}` ,{
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
        });
        const data = await r.json();
        content = data?.candidates?.[0]?.content?.parts?.[0]?.text || content;
      } else {
        const r = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${openaiKey}` },
          body: JSON.stringify({ model: 'gpt-4o-mini', messages: [
            { role: 'system', content: 'You are TruResetX AI Coach. Be concise, actionable, and safe.' },
            { role: 'user', content: prompt },
          ], temperature: 0.7 })
        });
        const data = await r.json();
        content = data?.choices?.[0]?.message?.content || content;
      }
    }

    // Log to Firestore (best-effort)
    try {
      const db = admin.firestore();
      await db.collection('aiSessions').add({
        uid, type: 'coach', goal, mood, content, created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch {}

    return res.json({ content });
  } catch (e) {
    return res.status(500).json({ error: 'ai_failed' });
  }
});

// Progress ingest endpoint: validates and writes server-side
app.post('/progress/ingest', verifyFirebaseToken, async (req, res) => {
  const { type, payload } = req.body || {};
  const uid = req.user?.uid;
  if (!type) return res.status(400).json({ error: 'missing_type' });
  try {
    const db = admin.firestore();
    const now = new Date();
    const dateKey = `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-${String(now.getDate()).padStart(2,'0')}`;
    if (type === 'workout') {
      await db.collection('workouts').add({ userId: uid, ...payload, date: dateKey, created_at: admin.firestore.FieldValue.serverTimestamp() });
    } else if (type === 'meal') {
      await db.collection('meals').add({ userId: uid, ...payload, date: dateKey, created_at: admin.firestore.FieldValue.serverTimestamp() });
    } else if (type === 'mood') {
      await db.collection('moodLogs').add({ userId: uid, ...payload, date: dateKey, created_at: admin.firestore.FieldValue.serverTimestamp() });
    } else {
      return res.status(400).json({ error: 'unknown_type' });
    }
    return res.json({ ok: true });
  } catch (e) {
    return res.status(500).json({ error: 'ingest_failed' });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`🔥 Blade API running on ${port}`));


