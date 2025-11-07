import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
// Using native fetch API (Node.js 18+)
import { populateCalendarEvents } from "./populateCalendarEvents";
import { generateMeditation, aiTherapyChat, aiCrisisCheckin } from "./mentalHealthFunctions";
import { seedSpiritualData } from "./seedSpiritualData";
import { seedAllFeaturesData } from "./seedAllFeaturesData";
import { populateSpiritualCalendar } from "./spiritualCalendar";
import { genkitHello } from "./genkitExample";

// Initialize Firebase Admin and default region early so functions can reference { region }
// Initialize Firebase Admin SDK once. In emulator environments the admin
// SDK may be initialized by the emulator runtime; guard to avoid duplicate init.
if (!admin.apps || admin.apps.length === 0) {
  admin.initializeApp();
}
const region = "asia-south1";

// Map Firebase Functions config keys to process.env for compatibility
// so that code paths using process.env continue to work after deploy.
// Note: firebase-functions v2 may not expose a typed `config` method. Cast to any to be resilient.
try {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const cfg: any = (functions as any).config?.() || {};
  if (!process.env.OPENAI_API_KEY && cfg.openai?.key) {
    process.env.OPENAI_API_KEY = cfg.openai.key as string;
  }
  if (!process.env.GEMINI_API_KEY && cfg.gemini?.key) {
    process.env.GEMINI_API_KEY = cfg.gemini.key as string;
  }
  if (!process.env.GENAI_API_KEY && cfg.genai?.key) {
    process.env.GENAI_API_KEY = cfg.genai.key as string;
  }
} catch {
  // functions.config() may not be available in local emulation without config set
}

// Export populateCalendarEvents for deployment
export { populateCalendarEvents };

// Export genkit example function
export { genkitHello };

// Export mental health functions
export { generateMeditation, aiTherapyChat, aiCrisisCheckin };
// Export scheduled job
export { populateSpiritualCalendar };

// Seed spiritual data function (call via HTTP)
export const seedSpiritualDataFunction = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
      await seedSpiritualData();
      return { success: true, message: "Spiritual data seeded successfully" };
    } catch (error: any) {
      console.error("Seeding error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to seed data");
    }
  }
);

// (admin initialized and region declared at top)

// Seed ALL features data function (call via HTTP)
export const seedAllFeaturesDataFunction = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
      await seedAllFeaturesData();
      return { success: true, message: "All features data seeded successfully" };
    } catch (error: any) {
      console.error("Seeding error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to seed data");
    }
  }
);

// Spiritual feature functions with AI integration
export const getDailySpiritualStory = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    try {
      const db = admin.firestore();
      const userDoc = await db.collection("users").doc(uid).get();
      const traditions = userDoc.data()?.traditions || ["Universal"];

  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const traditionText = traditions.join(", ");

      const prompt = `Generate a short spiritual story or parable (200-300 words) inspired by ${traditionText} traditions. Make it uplifting, meaningful, and suitable for daily reflection. Return JSON: {title, text, moral}`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
          }
        );
        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        return JSON.parse(jsonMatch ? jsonMatch[0] : '{"title":"Daily Story","text":"A moment of reflection.","moral":"Inner peace comes from within."}');
      } else {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: "You are a spiritual storyteller. Generate meaningful parables in JSON format." },
              { role: "user", content: prompt },
            ],
            temperature: 0.8,
            max_tokens: 400,
            response_format: { type: "json_object" },
          }),
        });
        const data: any = await response.json();
        return JSON.parse(data.choices[0]?.message?.content || "{}");
      }
    } catch (error: any) {
      console.error("Spiritual story error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate story");
    }
  }
);

export const generateSoulGrowthSummary = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    try {
      const { entries = [] } = request.data || {};
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const entriesText = entries.slice(0, 10).map((e: any) => `${e.type}: ${e.text?.substring(0, 100)}`).join("\n");

      const prompt = `Analyze these gratitude/reflection journal entries and provide:
1. Summary of growth themes (2-3 sentences)
2. Notable patterns (list)
3. Soul growth score (0-100)
Return JSON: {summary, themes[], score}`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ contents: [{ parts: [{ text: `${prompt}\n\nEntries:\n${entriesText}` }] }] }),
          }
        );
        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        return JSON.parse(jsonMatch ? jsonMatch[0] : '{"summary":"Growth in progress.","themes":[],"score":65}');
      } else {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: "You analyze spiritual journal entries and provide growth insights." },
              { role: "user", content: `${prompt}\n\nEntries:\n${entriesText}` },
            ],
            temperature: 0.7,
            max_tokens: 300,
            response_format: { type: "json_object" },
          }),
        });
        const data: any = await response.json();
        return JSON.parse(data.choices[0]?.message?.content || "{}");
      }
    } catch (error: any) {
      console.error("Soul growth summary error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate summary");
    }
  }
);

export const getReflectionPrompt = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    try {
      const { tradition = "Universal" } = request.data || {};
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const prompt = `Generate a thoughtful reflection prompt (1-2 sentences) for ${tradition} spiritual practice. Make it meaningful and actionable. Return JSON: {prompt}`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }) }
        );
        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        return JSON.parse(jsonMatch ? jsonMatch[0] : '{"prompt":"What act of service can you offer today?"}');
      } else {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [{ role: "system", content: "Generate spiritual reflection prompts." }, { role: "user", content: prompt }],
            temperature: 0.8,
            max_tokens: 100,
            response_format: { type: "json_object" },
          }),
        });
        const data: any = await response.json();
        return JSON.parse(data.choices[0]?.message?.content || "{}");
      }
    } catch (error: any) {
      console.error("Reflection prompt error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate prompt");
    }
  }
);

export const generateYogaSequence = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    try {
      const { duration = 20, focus = "relaxation" } = request.data || {};
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const prompt = `Generate a ${duration}-minute yoga sequence focused on ${focus}. Include poses, durations in seconds, and brief notes. Return JSON: {name, duration_minutes, poses: [{name, duration_sec, notes?}]}`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }) }
        );
        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        return JSON.parse(jsonMatch ? jsonMatch[0] : '{"name":"Relaxation Flow","duration_minutes":20,"poses":[]}');
      } else {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [{ role: "system", content: "Generate yoga sequences in JSON format." }, { role: "user", content: prompt }],
            temperature: 0.7,
            max_tokens: 500,
            response_format: { type: "json_object" },
          }),
        });
        const data: any = await response.json();
        return JSON.parse(data.choices[0]?.message?.content || "{}");
      }
    } catch (error: any) {
      console.error("Yoga sequence error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate sequence");
    }
  }
);

export const faithAIChat = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    const { message = "", tradition = "Universal", history = [] } = request.data || {};
    if (!message || typeof message !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Message is required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const systemPrompt = `You are a ${tradition} spiritual guide and advisor. Answer questions with wisdom, empathy, and respect for ${tradition} teachings. Be supportive and offer practical spiritual guidance.`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: `${systemPrompt}\n\nUser: ${message}` }] }],
            }),
          }
        );
        const data: any = await response.json();
        return { content: data.candidates[0]?.content?.parts[0]?.text || "I apologize, I couldn't generate a response." };
      } else {
        const messages: any[] = [{ role: "system", content: systemPrompt }];
        if (history && history.length > 0) {
          messages.push(...history.map((h: any) => ({ role: h.role || "user", content: h.content || "" })));
        }
        messages.push({ role: "user", content: message });

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: messages,
            temperature: 0.7,
            max_tokens: 500,
          }),
        });
        const data: any = await response.json();
        return { content: data.choices[0]?.message?.content || "I apologize, I couldn't generate a response." };
      }
    } catch (error: any) {
      console.error("Faith AI chat error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get AI response");
    }
  }
);

export const generateDailySpiritualFeed = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    try {
      const db = admin.firestore();
      const userDoc = await db.collection("users").doc(uid).get();
      const traditions = userDoc.data()?.traditions || ["Universal"];

  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const traditionText = traditions.join(", ");

      const prompt = `Generate a daily spiritual feed for ${traditionText} traditions. Include:
- An inspiring quote (1 sentence)
- A reflection prompt (question format)
- A gratitude prompt (question format)
Return JSON: {daily_quote, reflection_prompt, gratitude_prompt}`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }) }
        );
        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        const feed = JSON.parse(jsonMatch ? jsonMatch[0] : '{"daily_quote":"Be still and know.","reflection_prompt":"What are you grateful for today?","gratitude_prompt":"List three simple joys."}');
        return {
          today_meditation: null,
          daily_quote: feed.daily_quote || "Be still and know.",
          spiritual_story: null,
          faith_highlight: null,
          reflection_prompt: feed.reflection_prompt || "What are you grateful for today?",
          gratitude_prompt: feed.gratitude_prompt || "List three simple joys.",
          yoga_suggestion: null,
        };
      } else {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: "Generate daily spiritual feed content in JSON format." },
              { role: "user", content: prompt },
            ],
            temperature: 0.8,
            max_tokens: 200,
            response_format: { type: "json_object" },
          }),
        });
        const data: any = await response.json();
        const feed = JSON.parse(data.choices[0]?.message?.content || "{}");
        return {
          today_meditation: null,
          daily_quote: feed.daily_quote || "Be still and know.",
          spiritual_story: null,
          faith_highlight: null,
          reflection_prompt: feed.reflection_prompt || "What are you grateful for today?",
          gratitude_prompt: feed.gratitude_prompt || "List three simple joys.",
          yoga_suggestion: null,
        };
      }
    } catch (error: any) {
      console.error("Daily spiritual feed error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate feed");
    }
  }
);

// Generic chat completion used by AIChatService
export const chatCompletion = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    const { message = "", history = [], context = "" } = request.data || {};
    if (!message || typeof message !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Message is required");
    }

    try {
      const openaiApiKey = process.env.OPENAI_API_KEY;
      const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      if (useGemini) {
        const sys = `You are TruResetX AI Coach. Keep responses concise and helpful. Context: ${context || "none"}`;
        const contents = [
          { parts: [{ text: sys }] },
          ...history.map((h: any) => ({ parts: [{ text: `${h.role || "user"}: ${h.content || ""}` }] })),
          { parts: [{ text: `user: ${message}` }] },
        ];
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ contents }) }
        );
        const data: any = await response.json();
        const content = data.candidates?.[0]?.content?.parts?.[0]?.text || "I couldn't generate a response.";
        return { content, model: "gemini-pro", tokens: data.usage?.totalTokenCount ?? 0 };
      } else {
        const messages: any[] = [
          { role: "system", content: `You are TruResetX AI Coach. Context: ${context || "none"}` },
          ...history,
          { role: "user", content: message },
        ];
        const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({ model: "gpt-4o-mini", messages, temperature: 0.7 }),
        });
        const data: any = await response.json();
        return {
          content: data.choices?.[0]?.message?.content || "I couldn't generate a response.",
          model: data.model || "gpt-4o-mini",
          tokens: data.usage?.total_tokens ?? 0,
        };
      }
    } catch (error: any) {
      console.error("chatCompletion error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get AI response");
    }
  }
);

// Domain-aware chat used by DomainAwareCoachService
export const domainAwareChat = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");

    const { message = "", domain = "general", system_prompt = "", context = {}, history = [] } = request.data || {};
    if (!message || typeof message !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Message is required");
    }

    try {
      const openaiApiKey = process.env.OPENAI_API_KEY;
      const geminiApiKey = process.env.GEMINI_API_KEY;
      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError("failed-precondition", "AI API key not configured");
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;
      const sys = system_prompt || `You are TruResetX ${domain} coach. Keep answers concise and actionable.`;

      if (useGemini) {
        const contents = [
          { parts: [{ text: sys }] },
          { parts: [{ text: `Context: ${JSON.stringify(context).slice(0, 2000)}` }] },
          ...history.map((h: any) => ({ parts: [{ text: `${h.role || "user"}: ${h.content || ""}` }] })),
          { parts: [{ text: `user: ${message}` }] },
        ];
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ contents }) }
        );
        const data: any = await response.json();
        const content = data.candidates?.[0]?.content?.parts?.[0]?.text || "I couldn't generate a response.";
        return { content, model: "gemini-pro", tokens: data.usage?.totalTokenCount ?? 0 };
      } else {
        const messages: any[] = [
          { role: "system", content: sys },
          { role: "system", content: `Context: ${JSON.stringify(context).slice(0, 2000)}` },
          ...history,
          { role: "user", content: message },
        ];
        const response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
          body: JSON.stringify({ model: "gpt-4o-mini", messages, temperature: 0.7 }),
        });
        const data: any = await response.json();
        return {
          content: data.choices?.[0]?.message?.content || "I couldn't generate a response.",
          model: data.model || "gpt-4o-mini",
          tokens: data.usage?.total_tokens ?? 0,
        };
      }
    } catch (error: any) {
      console.error("domainAwareChat error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get AI response");
    }
  }
);

// Helper to verify ID token
async function verifyIdToken(req: functions.https.Request): Promise<string> {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new functions.https.HttpsError("unauthenticated", "Missing auth token");
  }
  const token = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken.uid;
  } catch (error) {
    throw new functions.https.HttpsError("unauthenticated", "Invalid token");
  }
}

/**
 * Aggregate Today - Recompute today's summary
 */
export const aggregateToday = functions.https.onRequest(
  { region, cors: true },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    try {
      const uid = await verifyIdToken(req);
      const db = admin.firestore();

      // Get today's key
      const now = new Date();
      const todayKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;

      // Fetch today's logs
      const [moodLogs, mealLogs, practiceLogs, workoutSessions] = await Promise.all([
        db.collection(`users/${uid}/mood_logs`)
          .where("at", ">=", new Date(now.getFullYear(), now.getMonth(), now.getDate()))
          .where("at", "<", new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))
          .get(),
        db.collection(`users/${uid}/meal_logs`)
          .where("at", ">=", new Date(now.getFullYear(), now.getMonth(), now.getDate()))
          .where("at", "<", new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))
          .get(),
        db.collection(`users/${uid}/practice_logs`)
          .where("at", ">=", new Date(now.getFullYear(), now.getMonth(), now.getDate()))
          .where("at", "<", new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))
          .get(),
        db.collection(`users/${uid}/workout_sessions`)
          .where("started_at", ">=", new Date(now.getFullYear(), now.getMonth(), now.getDate()))
          .where("started_at", "<", new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))
          .get(),
      ]);

      // Calculate aggregates
      const calories = mealLogs.docs.reduce((sum, doc) => {
        const data = doc.data() || {};
        return sum + ((data.total && data.total.kcal) || 0);
      }, 0);

      const moodScores = moodLogs.docs
        .map((doc) => doc.data()?.score)
        .filter(Boolean);
      const avgMood = moodScores.length > 0
        ? moodScores.reduce((a, b) => a + b, 0) / moodScores.length
        : null;
      const latestMood = moodScores.length > 0 ? moodScores[moodScores.length - 1] : null;

      const practiceCount = practiceLogs.docs.length;
  const completedPracticeIds = [...new Set(practiceLogs.docs.map((doc) => doc.data()?.practice_id))];

  const workoutCount = workoutSessions.docs.filter((doc) => doc.data()?.status === "done").length;

      // Calculate streak
      let streak = 0;
      for (let i = 0; i < 365; i++) {
        const checkDate = new Date(now);
        checkDate.setDate(checkDate.getDate() - i);
  // checkKey intentionally unused; removed to satisfy noUnusedLocals
        
        const practiceCheck = await db.collection(`users/${uid}/practice_logs`)
          .where("at", ">=", new Date(checkDate.getFullYear(), checkDate.getMonth(), checkDate.getDate()))
          .where("at", "<", new Date(checkDate.getFullYear(), checkDate.getMonth(), checkDate.getDate() + 1))
          .limit(1)
          .get();

        if (practiceCheck.empty) break;
        streak++;
      }

      // Update today document
      const todayRef = db.collection("users").doc(uid).collection("today").doc(todayKey);
      await todayRef.set({
        date: admin.firestore.Timestamp.fromDate(now),
        streak,
        calories,
        water_ml: 0, // Will be updated separately
        workouts: {
          done: workoutCount,
          target: 1,
        },
        mood: {
          latest: latestMood,
          average: avgMood,
          last_logged_at: moodLogs.docs.length > 0
            ? moodLogs.docs[moodLogs.docs.length - 1].data()?.at
            : null,
        },
        sadhana: {
          done: practiceCount,
          target: 3,
          completed_practices: completedPracticeIds,
        },
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      res.json({ ok: true, streak, calories, mood: { latest: latestMood, average: avgMood } });
    } catch (error: any) {
      console.error("Error aggregating today:", error);
      res.status(500).json({ error: error.message });
    }
  }
);

/**
 * Nutrition Scan - Barcode to food lookup
 */
export const nutritionScan = functions.https.onCall(
  { region },
  async (request) => {
    const { barcode } = request.data;
    if (!barcode) {
      throw new functions.https.HttpsError("invalid-argument", "Barcode required");
    }

    try {
      // TODO: Integrate with Open Food Facts API or similar
      // For now, return mock data
      const db = admin.firestore();
      const foodRef = db.collection("foods").doc(barcode);
      const foodDoc = await foodRef.get();

      if (foodDoc.exists) {
  const foodData = foodDoc.data() || {};
  return { id: foodDoc.id, ...foodData };
      }

      // If not found, you would call external API here
      // Then store in /foods collection for future lookups

      return { error: "Food not found" };
    } catch (error: any) {
      throw new functions.https.HttpsError("internal", error.message);
    }
  }
);

/**
 * Daily Card - Generate spiritual daily card
 */
export const dailyCard = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    try {
      const db = admin.firestore();
      const userDoc = await db.collection("users").doc(uid).get();
  const userData = userDoc.data() || {};
      const traditions = userData?.traditions || [];

      // Generate daily card based on traditions and mood trends
      const now = new Date();
      const dateKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;

      // TODO: Integrate with AI (GPT/Gemini) for personalized content
      const dailyCardData = {
        verse: "Peace comes from within. Do not seek it without.",
        practice_id: "", // Random or AI-selected
        reflection_question: "What are you grateful for today?",
        tradition: traditions[0] || "Universal",
      };

      // Store daily card
      await db.collection("users").doc(uid).collection("daily_cards").doc(dateKey).set({
        ...dailyCardData,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      return dailyCardData;
    } catch (error: any) {
      throw new functions.https.HttpsError("internal", error.message);
    }
  }
);

/**
 * Coach Checkin - AI-powered summary and recommendations
 */
export const coachCheckin = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    try {
  // db not currently used in this handler; left out to avoid unused-local error

      // TODO: Integrate with AI for personalized insights
      const insights = {
        summary: "You're doing great! Keep up the momentum.",
        recommendations: [
          "Try a 10-minute meditation this evening",
          "Hydrate more - you're at 60% of your goal",
        ],
      };

      return insights;
    } catch (error: any) {
      throw new functions.https.HttpsError("internal", error.message);
    }
  }
);

// (Duplicate chatCompletion definition removed; consolidated implementation exists earlier.)

/**
 * Analyze Voice Transcript - CBT analysis using ChatGPT/Gemini
 */
export const analyzeVoiceTranscript = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { transcript, audio_url } = request.data;

    if (!transcript || typeof transcript !== "string" || transcript.trim().length === 0) {
      throw new functions.https.HttpsError("invalid-argument", "Transcript is required");
    }

    try {
      // Get AI API key (OpenAI or Gemini)
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      // Use OpenAI by default, fallback to Gemini
      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      // Build CBT analysis prompt
      const systemPrompt = `You are a Cognitive Behavioral Therapy (CBT) expert. Analyze the following voice transcript and extract:
1. Situation: What happened? (1-2 sentences)
2. Automatic Thoughts: What thoughts came to mind? (list)
3. Emotions: What emotions were expressed? (list)
4. Mood Score: Rate mood from 1-10 (number)
5. Evidence: Facts supporting or contradicting thoughts (list)
6. Cognitive Distortions: Identify any cognitive distortions present (list)
7. Alternative Perspective: How else could this be viewed? (2-3 sentences)
8. CBT Insights: Provide therapeutic insights and recommendations (list of 2-3 insights)

Return a JSON object with these fields. Be empathetic, supportive, and focus on evidence-based CBT techniques.`;

      let analysis: any;

      if (useGemini) {
        // Use Gemini API
  const geminiResponse = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              contents: [
                {
                  parts: [
                    {
                      text: `${systemPrompt}\n\nTranscript:\n${transcript}`,
                    },
                  ],
                },
              ],
            }),
          }
        );

        if (!geminiResponse.ok) {
          throw new Error(`Gemini API error: ${geminiResponse.statusText}`);
        }

        const geminiData: any = await geminiResponse.json();
        const responseText = geminiData.candidates[0]?.content?.parts[0]?.text || "";

        // Parse JSON from response
        try {
          analysis = JSON.parse(responseText);
        } catch {
          // If not JSON, create structured response
          analysis = {
            situation: transcript.substring(0, 100),
            thoughts: [],
            emotions: [],
            mood_score: 5,
            cognitive_distortions: [],
            alternative_perspective: responseText.substring(0, 200),
            cbt_insights: [responseText],
          };
        }
      } else {
        // Use OpenAI API
  const openaiResponse = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                {
                  role: "system",
                  content: systemPrompt,
                },
                {
                  role: "user",
                  content: `Please analyze this transcript:\n\n${transcript}`,
                },
              ],
              temperature: 0.7,
              max_tokens: 800,
              response_format: { type: "json_object" },
            }),
          }
        );

        if (!openaiResponse.ok) {
          const error: any = await openaiResponse.json();
          throw new Error(`OpenAI API error: ${error.error?.message || "Unknown error"}`);
        }

        const openaiData: any = await openaiResponse.json();
        const responseText = openaiData.choices[0]?.message?.content || "{}";

        try {
          analysis = JSON.parse(responseText);
        } catch {
          analysis = {
            situation: transcript.substring(0, 100),
            thoughts: [],
            emotions: [],
            mood_score: 5,
            cognitive_distortions: [],
            alternative_perspective: responseText.substring(0, 200),
            cbt_insights: [responseText],
          };
        }
      }

      // Ensure all required fields exist
      const structuredAnalysis = {
        situation: analysis.situation || transcript.substring(0, 100),
        thoughts: Array.isArray(analysis.thoughts)
          ? analysis.thoughts
          : analysis.automatic_thoughts || [],
        emotions: Array.isArray(analysis.emotions)
          ? analysis.emotions
          : [],
        mood_score: analysis.mood_score || analysis.moodScore || 5,
        cognitive_distortions: Array.isArray(analysis.cognitive_distortions)
          ? analysis.cognitive_distortions
          : [],
        evidence: Array.isArray(analysis.evidence) ? analysis.evidence : [],
        alternative_perspective: analysis.alternative_perspective || analysis.alternativePerspective || "",
        cbt_insights: Array.isArray(analysis.cbt_insights)
          ? analysis.cbt_insights
          : analysis.insights || [],
        model: useGemini ? "gemini-pro" : "gpt-4o-mini",
        audio_url: audio_url || null,
      };

      return structuredAnalysis;
    } catch (error: any) {
      console.error("Voice analysis error:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "Failed to analyze voice transcript"
      );
    }
  }
);

/**
 * Search Foods - Spoonacular API integration
 */
export const searchFoods = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { query } = request.data;
    if (!query || typeof query !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Query is required");
    }

    try {
  const spoonacularApiKey = process.env.SPOONACULAR_API_KEY;

      if (!spoonacularApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Spoonacular API key not configured"
        );
      }

      // Search Spoonacular API
  const response = await fetch(
        `https://api.spoonacular.com/food/products/search?query=${encodeURIComponent(query)}&number=20&apiKey=${spoonacularApiKey}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) {
        throw new Error(`Spoonacular API error: ${response.statusText}`);
      }

      const data: any = await response.json();
      const products = data.products || [];

      // Format results similar to HealthifyMe/Spoonacular
      return products.map((product: any) => ({
        id: product.id,
        title: product.title,
        image: product.image,
        nutrition: product.nutrition || {},
        badges: product.badges || [],
      }));
    } catch (error: any) {
      console.error("Food search error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to search foods");
    }
  }
);

/**
 * Scan Barcode - Lookup food by barcode (Spoonacular)
 */
export const scanBarcode = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { barcode } = request.data;
    if (!barcode || typeof barcode !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Barcode is required");
    }

    try {
  const spoonacularApiKey = process.env.SPOONACULAR_API_KEY;

      if (!spoonacularApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Spoonacular API key not configured"
        );
      }

      // Lookup product by barcode
  const response = await fetch(
        `https://api.spoonacular.com/food/products/upc/${barcode}?apiKey=${spoonacularApiKey}`,
        {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) {
        // Try alternative lookup method
  const altResponse = await fetch(
          `https://api.spoonacular.com/food/products/search?query=${encodeURIComponent(barcode)}&number=1&apiKey=${spoonacularApiKey}`,
        );

        if (!altResponse.ok) {
          throw new Error(`Product not found for barcode: ${barcode}`);
        }

        const altData: any = await altResponse.json();
        const product = altData.products?.[0];
        if (!product) {
          throw new Error(`Product not found for barcode: ${barcode}`);
        }

        return {
          id: product.id,
          title: product.title,
          image: product.image,
          barcode: barcode,
          nutrition: product.nutrition || {},
          serving_size: product.serving_size || "1 serving",
        };
      }

      const product: any = await response.json();
      return {
        id: product.id,
        title: product.title,
        image: product.image,
        barcode: barcode,
        nutrition: product.nutrition || {},
        serving_size: product.serving_size || "1 serving",
      };
    } catch (error: any) {
      console.error("Barcode scan error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to scan barcode");
    }
  }
);

/**
 * Get Food Details - Detailed nutrition info
 */
export const getFoodDetails = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { food_id } = request.data;
    if (!food_id || typeof food_id !== "number") {
      throw new functions.https.HttpsError("invalid-argument", "Food ID is required");
    }

    try {
  const spoonacularApiKey = process.env.SPOONACULAR_API_KEY;

      if (!spoonacularApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Spoonacular API key not configured"
        );
      }

      // Get detailed product info
  const response = await fetch(
        `https://api.spoonacular.com/food/products/${food_id}?apiKey=${spoonacularApiKey}`,
        {
          method: "GET",
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to get food details: ${response.statusText}`);
      }

      const product: any = await response.json();
      return {
        id: product.id,
        title: product.title,
        image: product.image,
        nutrition: product.nutrition || {},
        ingredients: product.ingredients || [],
        nutrition_grade: product.nutrition_grade || null,
      };
    } catch (error: any) {
      console.error("Get food details error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get food details");
    }
  }
);

/**
 * Generate Workout from Voice - AI workout generation
 */
export const generateWorkoutFromVoice = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { transcript, goal, duration, difficulty } = request.data;

    if (!transcript || typeof transcript !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Transcript is required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      const prompt = `Generate a workout plan based on the following user request: "${transcript}"

Requirements:
- Goal: ${goal || "general fitness"}
- Duration: ${duration || "30"} minutes
- Difficulty: ${difficulty || "intermediate"}
- Include warm-up, main exercises, and cool-down
- Provide exercise names, sets, reps, rest periods
- Include muscle groups targeted

Return a JSON object with this structure:
{
  "name": "Workout name",
  "goal": "workout goal",
  "duration_minutes": number,
  "difficulty": "beginner/intermediate/advanced",
  "warmup": [{"exercise": "name", "duration_sec": number}],
  "exercises": [{"name": "exercise", "sets": number, "reps": number or string, "rest_sec": number, "muscle_groups": [string]}],
  "cooldown": [{"exercise": "name", "duration_sec": number}],
  "calories_estimate": number
}`;

      let workout: any;

      if (useGemini) {
    const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        workout = JSON.parse(responseText);
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a fitness trainer. Generate workout plans in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 1000,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        workout = JSON.parse(responseText);
      }

      return workout;
    } catch (error: any) {
      console.error("Workout generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate workout");
    }
  }
);

/**
 * Generate Enhanced Workout - MuscleWiki-style with exercise library
 * Includes mood/spiritual adaptation
 */
export const generateEnhancedWorkout = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const {
      goal,
      equipment,
      duration_minutes,
      target_muscle_groups,
      available_exercises,
      exact_exercise_count,
      user_context,
    } = request.data;

    if (!goal || !equipment || !duration_minutes) {
      throw new functions.https.HttpsError("invalid-argument", "Goal, equipment, and duration are required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      // Build adaptive context prompt
      let contextPrompt = "";
      if (user_context) {
        if (user_context.has_low_energy) {
          contextPrompt += "User has low energy today - suggest lighter, recovery-focused exercises. ";
        }
        if (user_context.mood_score < 4) {
          contextPrompt += "User mood is low - include stress-relief and mood-boosting movements. ";
        }
        if (user_context.spiritual_streak_days > 7) {
          contextPrompt += "User has strong spiritual discipline - consider integrating mindful movement patterns. ";
        }
      }

      const exerciseCount = exact_exercise_count || Math.max(4, Math.floor(duration_minutes / 5));
      const exerciseList = (available_exercises || []).slice(0, 30).map((e: any) => e.name).join(", ");

      const prompt = `Generate a ${duration_minutes}-minute workout plan:

Goal: ${goal}
Equipment: ${equipment.join(", ")}
Target muscle groups: ${target_muscle_groups?.join(", ") || "full body"}
Exact number of exercises: ${exerciseCount}
${contextPrompt}
Available exercises: ${exerciseList}

Return JSON with this structure:
{
  "name": "Workout name",
  "goal": "${goal}",
  "duration_minutes": ${duration_minutes},
  "difficulty": "beginner/intermediate/advanced",
  "equipment_used": [${equipment.map((e: string) => `"${e}"`).join(", ")}],
  "warmup": [{"exercise_id": "id or name", "exercise_name": "name", "duration_sec": number}],
  "exercises": [{"exercise_id": "id or name", "exercise_name": "name", "sets": number, "reps": number or string, "rest_sec": number, "notes": "string"}],
  "cooldown": [{"exercise_id": "id or name", "exercise_name": "name", "duration_sec": number}],
  "calories_estimate": number,
  "muscle_groups_targeted": ${JSON.stringify(target_muscle_groups || [])},
  "rationale": "Brief explanation of why these exercises were chosen"
}

Match exercise names from available exercises list. Ensure exactly ${exerciseCount} exercises in the main routine.`;

      let workout: any;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        
        try {
          const jsonMatch = responseText.match(/\{[\s\S]*\}/);
          workout = JSON.parse(jsonMatch ? jsonMatch[0] : "{}");
        } catch {
          workout = JSON.parse(responseText);
        }
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a fitness trainer. Generate workout plans in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 1500,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        workout = JSON.parse(responseText);
      }

      return workout;
    } catch (error: any) {
      console.error("Enhanced workout generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate workout");
    }
  }
);

/**
 * Generate Workout - Text-based workout generation (Legacy)
 */
export const generateWorkout = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { description, goal, duration, difficulty, equipment, body_parts } = request.data;

    if (!description || typeof description !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Description is required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      const prompt = `Generate a workout plan:
- Description: ${description}
- Goal: ${goal || "general fitness"}
- Duration: ${duration || "30"} minutes
- Difficulty: ${difficulty || "intermediate"}
- Equipment: ${equipment?.join(", ") || "none"}
- Target body parts: ${body_parts?.join(", ") || "full body"}

Return JSON with: name, goal, duration_minutes, difficulty, warmup[], exercises[], cooldown[], calories_estimate`;

      let workout: any;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        workout = JSON.parse(responseText);
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a fitness trainer. Generate workout plans in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 1000,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        workout = JSON.parse(responseText);
      }

      return workout;
    } catch (error: any) {
      console.error("Workout generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate workout");
    }
  }
);

/**
 * Recognize Food from Image - HealthifyMe Snap feature
 * Uses OpenAI Vision API or Google Cloud Vision
 */
export const recognizeFood = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

  const { image_url } = request.data;
    if (!image_url || typeof image_url !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "Image URL is required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;

      if (!openaiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "OpenAI API key required for food recognition"
        );
      }

      // Use OpenAI Vision API
  const visionResponse = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${openaiApiKey}`,
        },
        body: JSON.stringify({
          model: "gpt-4o", // Vision-capable model
          messages: [
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: "Identify all foods in this image. Return JSON array: [{\"name\": \"food name\", \"portion\": \"estimated portion\", \"confidence\": 0-1, \"kcal_estimate\": number}]",
                },
                {
                  type: "image_url",
                  image_url: { url: image_url },
                },
              ],
            },
          ],
          max_tokens: 500,
          response_format: { type: "json_object" },
        }),
      });

      if (!visionResponse.ok) {
        throw new Error(`OpenAI Vision API error: ${visionResponse.statusText}`);
      }

      const visionData: any = await visionResponse.json();
      const recognitionText = visionData.choices[0]?.message?.content || "{\"foods\": []}";
      
      let foods: any[] = [];
      try {
        const parsed = JSON.parse(recognitionText);
        foods = parsed.foods || (Array.isArray(parsed) ? parsed : []);
      } catch (parseError) {
        // Fallback
        foods = [{ name: "Food detected", portion: "1 serving", confidence: 0.7, kcal_estimate: 0 }];
      }

      return {
        foods: foods,
        image_url: image_url,
        timestamp: new Date().toISOString(),
      };
    } catch (error: any) {
      console.error("Food recognition error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to recognize food");
    }
  }
);

/**
 * Recognize Meal (Multiple Foods) - Enhanced version
 */
export const recognizeMeal = functions.https.onCall(
  { region },
  async (request) => {
    // Not implemented — use recognizeFood via client call for now
    throw new functions.https.HttpsError("unavailable", "recognizeMeal is not implemented on the server; call recognizeFood or use the client-side meal recognition flow.");
  }
);

// (Duplicate domainAwareChat definition removed; consolidated implementation exists earlier.)

/**
 * Generate Daily Wisdom - AI-generated spiritual content
 */
export const generateDailyWisdom = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { traditions } = request.data;

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      const traditionText = traditions && traditions.length > 0
        ? `Focus on: ${traditions.join(", ")}`
        : "Universal spiritual wisdom";

      const prompt = `Generate a daily spiritual wisdom post:
- Traditions: ${traditionText}
- Include: inspirational quote, brief reflection (2-3 sentences), practice suggestion
- Be authentic, empathetic, and encouraging
- Return JSON: {quote, reflection, practice_suggestion, tradition}`;

      let wisdom: any;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";
        wisdom = JSON.parse(responseText);
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a spiritual guide. Generate daily wisdom in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.8,
              max_tokens: 300,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        wisdom = JSON.parse(responseText);
      }

      return wisdom;
    } catch (error: any) {
      console.error("Wisdom generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate wisdom");
    }
  }
);

/**
 * Get Daily Wisdom - Personalized wisdom based on mood and spiritual path
 */
export const getDailyWisdom = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { user_mood, spiritual_path, category } = request.data;

    try {
      const firestore = admin.firestore();
      let query: admin.firestore.Query = firestore.collection("wisdom");

      // Apply filters
      if (spiritual_path && spiritual_path !== "secular") {
        query = query.where("tradition", "==", spiritual_path);
      }

      if (user_mood) {
        query = query.where("mood_fit", "array-contains", user_mood);
      }

      if (category) {
        query = query.where("category", "==", category);
      }

      query = query.limit(10); // Get multiple for random selection
      const snapshot = await query.get();

      let wisdomDoc: admin.firestore.QueryDocumentSnapshot;
      let wisdom: any;

      if (snapshot.empty) {
        // Fallback to any random wisdom
        const randomSnapshot = await firestore.collection("wisdom").limit(10).get();
        if (randomSnapshot.empty) {
          throw new functions.https.HttpsError("not-found", "No wisdom found in database");
        }
        const randomIndex = Math.floor(Math.random() * randomSnapshot.docs.length);
        wisdomDoc = randomSnapshot.docs[randomIndex];
  wisdom = wisdomDoc.data() || {};
      } else {
        // Random selection from filtered results
        const randomIndex = Math.floor(Math.random() * snapshot.docs.length);
        wisdomDoc = snapshot.docs[randomIndex];
  wisdom = wisdomDoc.data() || {};
      }

      return {
        id: wisdomDoc.id,
        ...wisdom,
      };
    } catch (error: any) {
      console.error("Get daily wisdom error:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "Failed to get daily wisdom"
      );
    }
  }
);

/**
 * Get Wisdom Reflection - AI-powered reflection on wisdom
 */
export const getWisdomReflection = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { wisdom_id, reflection_prompt } = request.data;

    if (!wisdom_id || !reflection_prompt) {
      throw new functions.https.HttpsError("invalid-argument", "Wisdom ID and reflection prompt required");
    }

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      // Get wisdom content
      const firestore = admin.firestore();
      const wisdomDoc = await firestore.collection("wisdom").doc(wisdom_id).get();
      if (!wisdomDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Wisdom not found");
      }

  const wisdom = wisdomDoc.data() || {};
      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      const prompt = `You are a wisdom reflection guide. A user is reflecting on this wisdom:

"${wisdom?.translation}"

From: ${wisdom?.source || "Unknown"}
Category: ${wisdom?.category || "General"}

User's reflection: "${reflection_prompt}"

Provide:
1. Key insights connecting the wisdom to their reflection
2. Practical applications in daily life
3. Questions for deeper contemplation
4. How this relates to their wellness journey (body, mind, spirit)

Keep it supportive, insightful, and actionable. Format as JSON with keys: insights[], applications[], questions[], wellness_connection.`;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";

        try {
          const jsonMatch = responseText.match(/\{[\s\S]*\}/);
          return JSON.parse(jsonMatch ? jsonMatch[0] : "{}");
        } catch {
          return { insights: [], applications: [], questions: [], wellness_connection: "" };
        }
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a wisdom reflection guide. Provide insightful, actionable reflections." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 500,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        return JSON.parse(responseText);
      }
    } catch (error: any) {
      console.error("Wisdom reflection error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get reflection");
    }
  }
);

/**
 * Generate Meal Plan - AI-generated personalized meal plans
 */
export const generateMealPlan = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const {
      days,
      goal,
      target_calories,
      dietary_restrictions,
      preferences,
      user_context,
      include_spiritual_fasting,
    } = request.data;

    try {
  const openaiApiKey = process.env.OPENAI_API_KEY;
  const geminiApiKey = process.env.GEMINI_API_KEY;

      if (!openaiApiKey && !geminiApiKey) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "AI API key not configured"
        );
      }

      const useGemini = !openaiApiKey && geminiApiKey;
      const apiKey = useGemini ? geminiApiKey : openaiApiKey;

      const prompt = `Generate a ${days}-day personalized meal plan:

User Context:
- Goal: ${goal || 'maintenance'}
- Target calories: ${target_calories || 2000} kcal/day
- Dietary restrictions: ${(dietary_restrictions || []).join(", ") || "None"}
- Preferences: ${(preferences || []).join(", ") || "None"}
- Height: ${user_context?.height_cm || "N/A"} cm
- Weight: ${user_context?.weight_kg || "N/A"} kg
- Avg mood (7d): ${user_context?.avg_mood_7d || 5.0}
- Spiritual streak: ${user_context?.spiritual_streak || 0} days
- Include spiritual fasting: ${include_spiritual_fasting || false}

Return JSON:
{
  "plan_name": "Plan name",
  "days": ${days},
  "total_calories_per_day": ${target_calories},
  "meals": {
    "YYYY-MM-DD": [
      {
        "meal_type": "breakfast/lunch/dinner/snack",
        "foods": [
          {
            "name": "Food name",
            "quantity": "1 serving",
            "kcal": number,
            "protein": number,
            "carbs": number,
            "fat": number
          }
        ],
        "total_kcal": number,
        "notes": "Optional meal notes"
      }
    ]
  },
  "weekly_summary": {
    "total_kcal": number,
    "avg_protein": number,
    "avg_carbs": number,
    "avg_fat": number
  },
  "considerations": "Any special considerations for this plan"
}

Generate realistic meals with proper macronutrient distribution.`;

      let mealPlan: any;

      if (useGemini) {
        const response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.candidates[0]?.content?.parts[0]?.text || "{}";

        try {
          const jsonMatch = responseText.match(/\{[\s\S]*\}/);
          mealPlan = JSON.parse(jsonMatch ? jsonMatch[0] : "{}");
        } catch {
          mealPlan = {};
        }
      } else {
        const response = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: "You are a nutrition expert. Generate personalized meal plans in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 2000,
              response_format: { type: "json_object" },
            }),
          }
        );

        const data: any = await response.json();
        const responseText = data.choices[0]?.message?.content || "{}";
        mealPlan = JSON.parse(responseText);
      }

      return mealPlan;
    } catch (error: any) {
      console.error("Meal plan generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate meal plan");
    }
  }
);

/**
 * Schedule Notifications - Send scheduled nudges
 */
export const scheduleNotifications = functions.scheduler.onSchedule(
  { schedule: "every 1 hours", region },
  async () => {
    const db = admin.firestore();

    // Find users who need hydration reminders
    const usersSnapshot = await db.collection("users")
      .where("settings.push.hydration_nudges", "==", true)
      .get();

    for (const userDoc of usersSnapshot.docs) {
      const uid = userDoc.id;
      void uid; // placeholder to mark uid as intentionally unused for now
      // Check if user needs reminder (e.g., low water intake)
      // Send FCM notification
      // Implementation depends on your notification service
    }
  }
);

