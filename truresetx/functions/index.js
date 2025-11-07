const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Recompute daily aggregates for a user when entries change.
 * Triggered on writes to: users/{uid}/entries/{entryId}
 */
exports.aggregateDaily = functions.firestore
  .document('users/{uid}/entries/{entryId}')
  .onWrite(async (change, context) => {
    try {
      const { uid } = context.params;
      // Determine the date from the new or old entry
      const doc = change.after.exists ? change.after.data() : change.before.data();
      if (!doc) return null;
      const recordedAt = doc.recordedAt ? new Date(doc.recordedAt) : new Date();
      const yyyy = recordedAt.getFullYear();
      const mm = String(recordedAt.getMonth() + 1).padStart(2, '0');
      const dd = String(recordedAt.getDate()).padStart(2, '0');
      const dayId = `${yyyy}-${mm}-${dd}`;

      // Query all entries for that user/date
      const start = new Date(yyyy, recordedAt.getMonth(), recordedAt.getDate());
      start.setHours(0,0,0,0);
      const end = new Date(start);
      end.setDate(end.getDate() + 1);

      const snaps = await db.collection(`users/${uid}/entries`)
        .where('recordedAt', '>=', start.toISOString())
        .where('recordedAt', '<', end.toISOString())
        .get();

      let moodSum = 0; let moodCount = 0;
      let sleepMin = 0; let sleepCount = 0;
      let calories = 0;

      snaps.forEach(s => {
        const d = s.data();
        if (d.type === 'mood' && typeof d.value === 'number') {
          moodSum += d.value; moodCount += 1;
        }
        if (d.type === 'sleep' && typeof d.minutes === 'number') {
          sleepMin += d.minutes; sleepCount += 1;
        }
        if (d.type === 'meal' && typeof d.calories === 'number') {
          calories += d.calories;
        }
      });

      const docRef = db.doc(`users/${uid}/daily/${dayId}`);
      const data = {
        date: dayId,
        mood_avg: moodCount ? (moodSum / moodCount) : null,
        sleep_min: sleepCount ? Math.round(sleepMin / sleepCount) : null,
        calories_total: calories,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await docRef.set(data, { merge: true });

      // Push simple recommendations based on thresholds
      const recs = [];
      if (data.mood_avg !== null && data.mood_avg <= 4.0) {
        recs.push({ title: 'Low mood support', body: 'Try a 2-min grounding exercise.', userId: uid });
      }
      if (data.sleep_min !== null && data.sleep_min < 360) { // <6h
        recs.push({ title: 'Low sleep', body: 'Wind-down meditation recommended.', userId: uid });
      }

      for (const r of recs) {
        // Write to mw_recommendations to match the app's Firestore adapter
        await db.collection('mw_recommendations').add({
          user_id: r.userId,
          title: r.title,
          body: r.body,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          source: 'aggregateDaily',
        });
      }

      return null;
    } catch (err) {
      console.error('aggregateDaily error', err);
      return null;
    }
  });

// Simple HTTP endpoint to force recompute for a user/day (for testing)
exports.recomputeDaily = functions.https.onRequest(async (req, res) => {
  try {
    const uid = req.query.uid;
    const date = req.query.date; // YYYY-MM-DD
    if (!uid || !date) return res.status(400).send('uid and date required');

    // Query entries for that day and reuse logic by invoking aggregateDaily-like computation
    const [yyyy, mm, dd] = date.split('-').map(Number);
    const start = new Date(yyyy, mm - 1, dd);
    start.setHours(0,0,0,0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);

    const snaps = await db.collection(`users/${uid}/entries`)
      .where('recordedAt', '>=', start.toISOString())
      .where('recordedAt', '<', end.toISOString())
      .get();

    let moodSum = 0; let moodCount = 0;
    let sleepMin = 0; let sleepCount = 0;
    let calories = 0;

    snaps.forEach(s => {
      const d = s.data();
      if (d.type === 'mood' && typeof d.value === 'number') {
        moodSum += d.value; moodCount += 1;
      }
      if (d.type === 'sleep' && typeof d.minutes === 'number') {
        sleepMin += d.minutes; sleepCount += 1;
      }
      if (d.type === 'meal' && typeof d.calories === 'number') {
        calories += d.calories;
      }
    });

    const dayId = date;
    const docRef = db.doc(`users/${uid}/daily/${dayId}`);
    const data = {
      date: dayId,
      mood_avg: moodCount ? (moodSum / moodCount) : null,
      sleep_min: sleepCount ? Math.round(sleepMin / sleepCount) : null,
      calories_total: calories,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await docRef.set(data, { merge: true });
    return res.status(200).json({ ok: true, data });
  } catch (err) {
    console.error('recomputeDaily error', err);
    return res.status(500).send('error');
  }
});
const functions = require('firebase-functions');
const admin = require('firebase-admin');

try {
  admin.initializeApp();
} catch (e) {
  // ignore if already initialized in local emulator
}

// Simple HTTP function stub that returns a generated recommendation.
// Replace with a secure implementation (and validate auth) for production.
exports.generateRecommendation = functions.https.onRequest(async (req, res) => {
  const userId = req.query.userId || (req.body && req.body.userId) || 'anonymous';
  // Very small deterministic demo recommendation
  const rec = {
    id: `rec-${Date.now()}`,
    title: 'Try a grounding breath',
    body: 'Take 3 deep breaths (4s inhale, 6s exhale) and notice the ground under your feet.',
    created_at: new Date().toISOString(),
    user_id: userId,
  };

  res.json({ok: true, recommendation: rec});
});
