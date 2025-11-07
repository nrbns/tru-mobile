/* eslint-disable */
declare const Deno: any;
// @ts-ignore
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore
import { z } from "https://esm.sh/zod@3";
import { json, getUserIdFromRequest } from "../_shared/helpers.ts";

serve(async (req: Request) => {
  try {
    const body = await req.json();
    const s = z.object({ set_id: z.number().int() });
    const v = s.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    const row = await sb.from('sets_logs').select('*').eq('id', v.set_id).maybeSingle();
    const data = row.data;
    if (!data) return json({ ok: false, error: 'set not found' }, 404);

    const repMetrics = data.rep_metrics ?? [];
    const arScores = data.ar_scores ?? { avg: 0, errors: {} };

    // pick top error
    const errors = arScores.errors || {};
    const sorted = Object.entries(errors).sort((a: any, b: any) => (b[1] as number) - (a[1] as number));
    const primary = sorted.length ? sorted[0][0] : null;

    const suggestion = primary ? { cue: suggestionForError(primary), error: primary } : { cue: 'Good job', error: null };

    // Update sets_logs summary
    await sb.from('sets_logs').update({ ar_scores: arScores }).eq('id', v.set_id);

    return json({ ok: true, suggestion });
  } catch (e) {
    console.error(e);
    return json({ error: String(e) }, 500);
  }
});

function suggestionForError(err: string) {
  switch (err) {
    case 'depth_low':
      return 'Sit deeper; drive through heels.';
    case 'valgus':
      return 'Push knees out and track toes.';
    case 'tempo':
      return 'Slow down the eccentric; count 2s.';
    default:
      return 'Focus on control and symmetry.';
  }
}
