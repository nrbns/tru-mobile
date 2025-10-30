import * as functions from "firebase-functions/v2";
// Import genkit and the official plugin
import { genkit } from "genkit";
import { googleAI, gemini15Flash } from "@genkit-ai/googleai";

// Use the same region as other functions
const region = "asia-south1";

// Read API key from environment (populated from functions config in index.ts)
const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENAI_API_KEY || process.env.GENAI_API_KEY;

// Initialize a genkit instance with the Google AI plugin.
// We pass the apiKey into the plugin so we don't embed secrets in code.
const ai = genkit({
  plugins: [googleAI({ apiKey })],
  model: gemini15Flash,
});

// Example callable function that uses genkit to generate a small greeting.
export const genkitHello = functions.https.onCall(
  { region },
  async (request: any) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    if (!apiKey) {
      throw new functions.https.HttpsError("failed-precondition", "GenAI API key not configured");
    }

    const name = (request.data && request.data.name) || "friend";

    try {
      // Use genkit to generate text. The genkit API may return different shapes;
      // use a permissive any type and return a simple text field to callers.
      const result: any = await ai.generate(`Hello Gemini, my name is ${name}`);
      // genkit returns { text } in many cases, but plugins may vary. Normalize.
      const text = (result && (result.text || result.output || JSON.stringify(result))) || "";
      return { text };
    } catch (err: any) {
      console.error("genkitHello error:", err);
      throw new functions.https.HttpsError("internal", err?.message || "Failed to generate with GenKit");
    }
  }
);
