// This file runs on Deno (Supabase Edge Functions). Add minimal stubs for the editor/tsserver.
/* eslint-disable */
declare const Deno: any;
// @ts-ignore: remote import used at runtime in Deno
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore: remote import used at runtime in Deno
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore: remote import used at runtime in Deno
import { z } from "https://deno.land/x/zod@v3.21.4/mod.ts";
// @ts-ignore: remote import used at runtime in Deno
import OpenAI from "https://esm.sh/openai@4";

const schema = z.object({
  user_id: z.string(),
  goal: z.enum(["fat_loss", "muscle_gain", "recomp", "endurance"]),
  fitness_level: z.enum(["beginner", "intermediate", "advanced"]),
  time_per_day_min: z.number().min(10).max(120),
});

serve(async (req: Request) => {
  try {
    const input = schema.parse(await req.json());

    const SUPABASE_URL = (globalThis as any).Deno?.env.get("SUPABASE_URL")!;
    const SUPABASE_KEY = (globalThis as any).Deno?.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const OPENAI_KEY = (globalThis as any).Deno?.env.get("OPENAI_API_KEY")!;

    const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
    const openai = new OpenAI({ apiKey: OPENAI_KEY });

    // fetch recent assessments/logs if needed
    const { data: profile } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", input.user_id)
      .maybeSingle();

    const sys = `You are TruResetX Workout Planner. Output JSON only with a 28-day plan split into days and sessions. Respect time_per_day_min. Progress conservatively.`;
    const user = { ...input, profile };

    const r = await openai.responses.create({
      model: "gpt-4.1-mini",
      input: [
        { role: "system", content: sys },
        { role: "user", content: JSON.stringify(user) },
      ],
      response_format: { type: "json_object" },
    });

    // fallback: try to read text output if parsing direct JSON fails
    const plan = r.output?.[0]?.content?.[0]?.text ? JSON.parse(r.output[0].content[0].text) : (r.output_text ? JSON.parse(r.output_text) : {});

    await supabase.from("plans").insert({ user_id: input.user_id, plan_json: plan });

    return new Response(JSON.stringify({ ok: true, plan_id: plan.id ?? null, plan }), { headers: { "Content-Type": "application/json" } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
});
