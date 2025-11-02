import * as functions from "firebase-functions/v2";
// Import genkit and the official plugin
import { genkit } from "genkit";
import { googleAI, gemini15Flash } from "@genkit-ai/googleai";

// Use the same region as other functions
const region = "asia-south1";

// Read API key from environment (populated from functions config in index.ts)
const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GENAI_API_KEY || process.env.GENAI_API_KEY;

// Helpers
function sanitizeString(s: any, maxLen = 200) {
  if (s == null) return "";
  const str = String(s);
  return str.length > maxLen ? str.slice(0, maxLen) : str;
}

function safeParseJSON(text: any) {
  if (!text || typeof text !== "string") return null;
  try {
    const match = text.match(/\{[\s\S]*\}/);
    const toParse = match ? match[0] : text;
    return JSON.parse(toParse);
  } catch (e) {
    return null;
  }
}

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

  const name = sanitizeString((request.data && request.data.name) || "friend", 100);

    try {
      // Use genkit to generate text. The genkit API may return different shapes;
      // use a permissive any type and return a simple text field to callers.
      const result: any = await ai.generate(`Hello Gemini, my name is ${name}`);
      // genkit returns various shapes; normalize safely
      let text = "";
      if (result) {
        if (typeof result === "string") text = result;
        else if (result.text) text = String(result.text);
        else if (result.output) text = String(result.output);
        else text = JSON.stringify(result);
      }
      // If the response looks like JSON, attempt a safe parse and prefer a 'text' field
      const parsed = safeParseJSON(text);
      if (parsed && typeof parsed === "object" && parsed.text) {
        text = String(parsed.text);
      }
      // Truncate to avoid very large responses
      text = sanitizeString(text, 2000);
      return { text };
    } catch (err: any) {
      console.error("genkitHello error:", err);
      throw new functions.https.HttpsError("internal", err?.message || "Failed to generate with GenKit");
    }
  }
);
