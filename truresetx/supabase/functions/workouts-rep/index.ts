/* eslint-disable */
declare const Deno: any;
// @ts-ignore
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore
import { z } from "https://esm.sh/zod@3";
import { getUserIdFromRequest, json } from "../_shared/helpers.ts";
import { scoreRep } from "../_shared/ar_engine.ts";

serve(async (req: Request) => {
  try {
    const body = await req.json();
    const s = z.object({ set_id: z.number().int(), rep_index: z.number().int(), exercise_id: z.number().int().optional(), metrics: z.any() });
    const v = s.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    const userId = getUserIdFromRequest(req);

    // Load exercise ar rules if provided
    let rules = null;
    if (v.exercise_id) {
      const { data } = await sb.from('exercises').select('ar_err_rules').eq('id', v.exercise_id).maybeSingle();
      rules = data?.ar_err_rules ?? null;
    }

    const sc = scoreRep(v.metrics, rules);

    // Append to sets_logs (try update existing row by id, else insert)
    const existing = await sb.from('sets_logs').select('id,rep_metrics,ar_scores').eq('id', v.set_id).maybeSingle();
    if (existing.data) {
      const repMetrics = existing.data.rep_metrics ?? [];
      repMetrics.push(v.metrics);
      const arScores = existing.data.ar_scores ?? { avg: 0, errors: {} };
      // aggregate average naively
      arScores.avg = ((arScores.avg || 0) + sc.score) / (repMetrics.length);
      // merge errors
      arScores.errors = { ...(arScores.errors || {}), ...(sc.errors || {}) };
      await sb.from('sets_logs').update({ rep_metrics: repMetrics, ar_scores: arScores }).eq('id', v.set_id);
    } else {
      await sb.from('sets_logs').insert([{ id: v.set_id, rep_metrics: [v.metrics], ar_scores: { avg: sc.score, errors: sc.errors } }]);
    }

    return json({ ok: true, ar_score: sc });
  } catch (e) {
    console.error(e);
    return json({ error: String(e) }, 500);
  }
});
