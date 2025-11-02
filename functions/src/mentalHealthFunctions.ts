import * as functions from "firebase-functions/v2";
import fetch from "node-fetch";

const region = "asia-south1";

// Helpers
function sanitizeString(s: any, maxLen = 1000) {
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

/**
 * Generate AI Meditation Session - Headspace/Calm-style
 */
export const generateMeditation = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { goal, duration_minutes, user_context } = request.data || {};

    // Basic input validation & sanitization
    const safeGoal = sanitizeString(goal, 300);
    const safeDuration = Number(duration_minutes) || 0;
    const safeContext = sanitizeString(user_context, 2000);

    if (!safeGoal || safeDuration <= 0 || safeDuration > 180) {
      throw new functions.https.HttpsError("invalid-argument", "Goal and a valid duration (1-180 minutes) are required");
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

      const prompt = `You are a meditation guide. Generate a ${safeDuration}-minute guided meditation session for: ${safeGoal}.

${safeContext ? `User context: ${safeContext}` : ''}

Provide a structured meditation script in JSON format:
{
  "title": "Meditation title",
  "goal": "${safeGoal}",
  "duration_minutes": ${safeDuration},
  "script": [
    {"time": 0, "instruction": "Find a comfortable position..."},
    {"time": 60, "instruction": "Close your eyes..."}
  ],
  "background_music": "calming",
  "breathing_pattern": "4-4-4-4"
}`;

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

        if (!response.ok) {
          console.error("Gemini response not ok", response.status, await response.text().catch(() => ""));
          return { title: "Guided Meditation", script: [], duration_minutes: safeDuration };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
        const parsed = safeParseJSON(responseText);
        if (parsed) return parsed;
        return { title: "Guided Meditation", script: [], duration_minutes: safeDuration };
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
                { role: "system", content: "You are a meditation guide. Generate structured meditation scripts in JSON format." },
                { role: "user", content: prompt },
              ],
              temperature: 0.7,
              max_tokens: 1500,
              response_format: { type: "json_object" },
            }),
          }
        );

        if (!response.ok) {
          console.error("OpenAI response not ok", response.status, await response.text().catch(() => ""));
          return { title: "Guided Meditation", script: [], duration_minutes: safeDuration };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.choices?.[0]?.message?.content || "{}";
        const parsed = safeParseJSON(responseText) || (typeof responseText === "object" ? responseText : null);
        if (parsed) return parsed;
        try {
          return JSON.parse(responseText);
        } catch {
          return { title: "Guided Meditation", script: [], duration_minutes: safeDuration };
        }
      }
    } catch (error: any) {
      console.error("Meditation generation error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to generate meditation");
    }
  }
);

/**
 * AI Therapy Chat - Wysa/MindShift-style CBT chatbot
 */
export const aiTherapyChat = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const { message, recent_journals } = request.data || {};
    const safeMessage = sanitizeString(message, 2000);
    if (!safeMessage) {
      throw new functions.https.HttpsError("invalid-argument", "Message is required");
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

      let contextPrompt = "";
      if (recent_journals && Array.isArray(recent_journals)) {
        contextPrompt += "\nRecent journal entries:\n";
        recent_journals.slice(0, 3).forEach((j: any) => {
          contextPrompt += `- ${j.situation || ''} - ${j.thoughts || ''}\n`;
        });
      }

  const prompt = `You are a compassionate CBT (Cognitive Behavioral Therapy) therapist chatbot. The user wrote: "${safeMessage}"

${contextPrompt}

Respond with empathy and CBT techniques. Help them identify cognitive distortions and reframe thoughts. Be supportive, not clinical. Keep responses concise (2-3 sentences).

Return JSON:
{
  "response": "Your empathetic CBT response",
  "suggestions": ["Suggestion 1", "Suggestion 2"],
  "cbt_technique": "technique name"
}`;

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

        if (!response.ok) {
          console.error("Gemini therapy response not ok", response.status, await response.text().catch(() => ""));
          return { response: "I'm here to listen and support you.", suggestions: [] };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
        const parsed = safeParseJSON(responseText) || (typeof responseText === "object" ? responseText : null);
        if (parsed) return parsed;
        return { response: "I'm here to listen and support you.", suggestions: [] };
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
                { role: "system", content: "You are a compassionate CBT therapist. Respond with empathy and evidence-based techniques." },
                { role: "user", content: prompt },
              ],
              temperature: 0.8,
              max_tokens: 300,
              response_format: { type: "json_object" },
            }),
          }
        );

        if (!response.ok) {
          console.error("OpenAI therapy response not ok", response.status, await response.text().catch(() => ""));
          return { response: "I'm here to listen and support you.", suggestions: [] };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.choices?.[0]?.message?.content || "{}";
        const parsed = safeParseJSON(responseText) || (typeof responseText === "object" ? responseText : null);
        if (parsed) return parsed;
        try {
          return JSON.parse(responseText);
        } catch {
          return { response: "I'm here to listen and support you.", suggestions: [] };
        }
      }
    } catch (error: any) {
      console.error("Therapy chat error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to get therapy response");
    }
  }
);

/**
 * AI Crisis Check-in - Detects distress patterns
 */
export const aiCrisisCheckin = functions.https.onCall(
  { region },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

  const { recent_moods, user_message } = request.data || {};
  const safeUserMessage = sanitizeString(user_message, 2000);

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

      let contextPrompt = "";
      if (recent_moods && Array.isArray(recent_moods)) {
        const avgMood = recent_moods.reduce((sum: number, m: any) => sum + (m.score || 5), 0) / recent_moods.length;
        contextPrompt += `Recent average mood: ${avgMood.toFixed(1)}/10\n`;
      }

      if (safeUserMessage) {
        contextPrompt += `User message: "${safeUserMessage}"\n`;
      }

      const prompt = `Analyze the user's mental health state based on: ${contextPrompt}

Determine:
1. Risk level (low, moderate, high)
2. Whether to suggest immediate help (crisis helpline)
3. Coping strategies
4. Support recommendations

Return JSON:
{
  "risk_level": "low|moderate|high",
  "needs_immediate_help": false,
  "recommendations": ["Recommendation 1"],
  "coping_strategies": ["Strategy 1"],
  "should_contact_professional": false
}`;

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

        if (!response.ok) {
          console.error("Gemini crisis response not ok", response.status, await response.text().catch(() => ""));
          return { risk_level: "low", needs_immediate_help: false, recommendations: [], coping_strategies: [] };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
        const parsed = safeParseJSON(responseText) || (typeof responseText === "object" ? responseText : null);
        if (parsed) return parsed;
        return { risk_level: "low", needs_immediate_help: false, recommendations: [], coping_strategies: [] };
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
                { role: "system", content: "You are a mental health crisis detection system. Analyze user state and provide appropriate support recommendations." },
                { role: "user", content: prompt },
              ],
              temperature: 0.5,
              max_tokens: 300,
              response_format: { type: "json_object" },
            }),
          }
        );

        if (!response.ok) {
          console.error("OpenAI crisis response not ok", response.status, await response.text().catch(() => ""));
          return { risk_level: "low", needs_immediate_help: false, recommendations: [], coping_strategies: [] };
        }

        const data: any = await response.json().catch(() => ({}));
        const responseText = data.choices?.[0]?.message?.content || "{}";
        const parsed = safeParseJSON(responseText) || (typeof responseText === "object" ? responseText : null);
        if (parsed) return parsed;
        try {
          return JSON.parse(responseText);
        } catch {
          return { risk_level: "low", needs_immediate_help: false, recommendations: [], coping_strategies: [] };
        }
      }
    } catch (error: any) {
      console.error("Crisis check-in error:", error);
      throw new functions.https.HttpsError("internal", error.message || "Failed to analyze crisis state");
    }
  }
);

