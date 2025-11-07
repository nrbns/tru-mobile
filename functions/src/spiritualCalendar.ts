import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

const region = "asia-south1";

// Scheduled job to populate per-user spiritual calendar (moon phase + events) daily
export const populateSpiritualCalendar = functions
  .region(region)
  .pubsub.schedule("0 6 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const db = admin.firestore();

    const IPGEO_KEY = (functions as any).config()?.ipgeo?.key as string | undefined;
    const CALENDARIFIC_KEY = (functions as any).config()?.calendarific?.key as string | undefined;

    const usersSnap = await db.collection("users").get();
    const today = new Date();
    const todayStr = today.toISOString().split("T")[0];

    for (const userDoc of usersSnap.docs) {
      const user = userDoc.data() || {};
      const country = user.country || "IN";
      const lat = user.lat ?? 28.6139;
      const lng = user.long ?? 77.2090;
      const tradition = (user.traditions?.[0] as string) || user.tradition || "Universal";

      let moon: any = null;
      let holidays: any[] = [];
      let religiousEvents: any[] = [];

      try {
        if (IPGEO_KEY) {
          const moonRes = await axios.get(
            `https://api.ipgeolocation.io/astronomy?apiKey=${IPGEO_KEY}&lat=${lat}&long=${lng}`
          );
          moon = moonRes.data;
        }
      } catch (e) {
        // ignore and fallback
      }

      try {
        const year = todayStr.split("-")[0];
        const nagerRes = await axios.get(
          `https://date.nager.at/api/v3/PublicHolidays/${year}/${country}`
        );
        holidays = (nagerRes.data as any[]).filter(
          (h) => h.date === todayStr
        );
      } catch (e) {
        // ignore
      }

      try {
        if (CalendarificCountrySupported(country) && CALENDARIFIC_KEY) {
          const calRes = await axios.get(
            `https://calendarific.com/api/v2/holidays?api_key=${CALENDARIFIC_KEY}&country=${country}&year=${today.getFullYear()}&type=religious`
          );
          const list: any[] = calRes.data?.response?.holidays ?? [];
          religiousEvents = list.filter((h) => h.date?.iso === todayStr);
        }
      } catch (e) {
        // ignore
      }

      const events = [
        ...holidays.map((h) => ({
          name: h.localName || h.name,
          type: (h.types?.[0] as string) || "holiday",
          source: "nager",
        })),
        ...religiousEvents
          .filter((r) =>
            Array.isArray(r.type)
              ? r.type.some((t: string) => matchTradition(tradition, t))
              : matchTradition(tradition, r.type)
          )
          .map((r) => ({
            name: r.name,
            type: Array.isArray(r.type) ? r.type[0] : r.type,
            description: r.description,
            source: "calendarific",
          })),
      ];

      await userDoc.ref
        .collection("today")
        .doc("calendar")
        .set(
          {
            date: todayStr,
            moonPhase: moon?.moon_phase || null,
            illumination: moon?.moon_illumination || null,
            sunrise: moon?.sunrise || null,
            sunset: moon?.sunset || null,
            events,
            tradition,
            country,
            lat,
            lng,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
    }

    return null;
  });

function CalendarificCountrySupported(country: string): boolean {
  return Boolean(country && country.length === 2);
}

function matchTradition(userTradition: string, eventType: string): boolean {
  const t = userTradition.toLowerCase();
  const e = (eventType || "").toLowerCase();
  if (!t || !e) return true;
  if (t.includes("hindu")) return e.includes("hindu");
  if (t.includes("islam")) return e.includes("islam");
  if (t.includes("christ")) return e.includes("christ");
  if (t.includes("jew")) return e.includes("jew");
  return true; // universal fallback
}


