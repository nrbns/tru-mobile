const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Daily aggregator: run once a day and compute aggregates per user
exports.aggregateDaily = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const users = await admin.firestore().collection('users').listDocuments();
  const today = new Date().toISOString().slice(0,10);
  for (const userDoc of users) {
    try {
      const snaps = await userDoc.collection('telemetry')
        .where('type','==','heart_rate')
        .where('timestamp','>=', new Date(today + 'T00:00:00Z'))
        .get();
      let sum=0, count=0;
      snaps.forEach(s=>{ const v = s.data().value; if (typeof v === 'number') { sum+=v; count++; } });
      if (count>0) {
        await admin.firestore().collection('analytics').doc(`${userDoc.id}_${today}`).set({
          avg_hr_day: sum/count,
          hr_samples: count,
          date: today
        }, { merge:true });
      }
    } catch (e) {
      console.error('aggregateDaily error for user', userDoc.id, e);
    }
  }
  return null;
});

// Callable function to delete a user's data (requires proper security rules / auth check)
exports.deleteUserData = functions.https.onCall(async (data, context) => {
  const uid = context.auth && context.auth.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userRef = admin.firestore().collection('users').doc(uid);
  // delete telemetry
  const telemetry = await userRef.collection('telemetry').listDocuments();
  const devices = await userRef.collection('devices').listDocuments();

  const batch = admin.firestore().bulkWriter();
  telemetry.forEach(d => batch.delete(d));
  devices.forEach(d => batch.delete(d));

  // also delete top-level user doc if present
  batch.delete(userRef);

  await batch.close();
  return { status: 'started' };
});
