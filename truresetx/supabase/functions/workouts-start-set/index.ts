/* eslint-disable */
declare const Deno: any;
// @ts-ignore
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore
import { z } from "https://esm.sh/zod@3";

serve(async (req: Request) => {
  try {
    const body = await req.json();
    const s = z.object({ workout_id: z.number().int(), exercise_id: z.number().int(), set_no: z.number().int(), expected_reps: z.number().int() });
    const v = s.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    // Return AR targets based on exercise.ar_err_rules
    const { data } = await sb.from('exercises').select('id,ar_err_rules').eq('id', v.exercise_id).maybeSingle();
    const targets = { ar_rules: data?.ar_err_rules ?? {} };
    return new Response(JSON.stringify({ ok: true, targets }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'content-type': 'application/json' } });
  }
});
