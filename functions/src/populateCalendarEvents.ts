import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const region = "asia-south1";

/**
 * Populate calendar_events collection with sample festivals and astronomical events
 * Call via: https://asia-south1-PROJECT_ID.cloudfunctions.net/populateCalendarEvents
 */
export const populateCalendarEvents = functions
  .region(region)
  .https.onRequest(async (req, res) => {
    try {
      const firestore = admin.firestore();
      const eventsRef = firestore.collection("calendar_events");

      // Sample festivals for 2025 (Indian festivals as example)
      const festivals: Array<{
        type: string;
        date: Date;
        title: string;
        description?: string;
        tradition?: string;
        region?: string;
        icon?: string;
        priority?: number;
      }> = [
        // January 2025
        {
          type: "festival",
          date: new Date(2025, 0, 14), // Makar Sankranti
          title: "Makar Sankranti",
          description: "Celebration of harvest and sun's journey northward",
          tradition: "Hinduism",
          region: "India",
          icon: "🎉",
          priority: 10,
        },
        {
          type: "festival",
          date: new Date(2025, 0, 26), // Republic Day
          title: "Republic Day",
          description: "India's Republic Day celebration",
          tradition: "National",
          region: "India",
          icon: "🇮🇳",
          priority: 10,
        },
        // February 2025
        {
          type: "festival",
          date: new Date(2025, 1, 3), // Basant Panchami (estimated)
          title: "Basant Panchami",
          description: "Festival marking the arrival of spring",
          tradition: "Hinduism",
          region: "India",
          icon: "🌸",
          priority: 8,
        },
        // March 2025
        {
          type: "festival",
          date: new Date(2025, 2, 14), // Holi (estimated)
          title: "Holi",
          description: "Festival of colors and spring",
          tradition: "Hinduism",
          region: "India",
          icon: "🌈",
          priority: 10,
        },
        // April 2025
        {
          type: "festival",
          date: new Date(2025, 3, 14), // Ram Navami (estimated)
          title: "Ram Navami",
          description: "Birthday of Lord Rama",
          tradition: "Hinduism",
          region: "India",
          icon: "🙏",
          priority: 9,
        },
        // May 2025
        {
          type: "festival",
          date: new Date(2025, 4, 2), // Eid al-Fitr (estimated)
          title: "Eid al-Fitr",
          description: "Festival marking the end of Ramadan",
          tradition: "Islam",
          region: "Global",
          icon: "🌙",
          priority: 10,
        },
        // Universal astronomical events
        {
          type: "solstice",
          date: new Date(2025, 5, 21), // Summer Solstice
          title: "Summer Solstice",
          description: "Longest day of the year in Northern Hemisphere",
          tradition: "Universal",
          region: "Global",
          icon: "☀️",
          priority: 9,
        },
        {
          type: "solstice",
          date: new Date(2025, 11, 21), // Winter Solstice
          title: "Winter Solstice",
          description: "Shortest day of the year in Northern Hemisphere",
          tradition: "Universal",
          region: "Global",
          icon: "❄️",
          priority: 9,
        },
        {
          type: "equinox",
          date: new Date(2025, 2, 20), // Spring Equinox
          title: "Spring Equinox",
          description: "Equal day and night",
          tradition: "Universal",
          region: "Global",
          icon: "🌱",
          priority: 8,
        },
        {
          type: "equinox",
          date: new Date(2025, 8, 22), // Autumn Equinox
          title: "Autumn Equinox",
          description: "Equal day and night",
          tradition: "Universal",
          region: "Global",
          icon: "🍂",
          priority: 8,
        },
      ];

      // Batch write events
      const batch = firestore.batch();
      let count = 0;

      for (const festival of festivals) {
        const docRef = eventsRef.doc();
        batch.set(docRef, {
          type: festival.type,
          date: admin.firestore.Timestamp.fromDate(festival.date),
          title: festival.title,
          description: festival.description || null,
          tradition: festival.tradition || "Universal",
          region: festival.region || "Global",
          icon: festival.icon || null,
          priority: festival.priority || 5,
          isRecurring: false,
          metadata: {},
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        count++;
      }

      await batch.commit();

      res.status(200).json({
        success: true,
        message: `Populated ${count} calendar events`,
        count,
      });
    } catch (error: any) {
      console.error("Populate calendar events error:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Failed to populate calendar events",
      });
    }
  });

