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
    if (req.method === 'POST') {
      const body = await req.json();
      const s = z.object({ date: z.string(), answers: z.array(z.number().int().min(0).max(5)) });
      const v = s.parse(body);
      const raw = (v.answers as number[]).reduce((a,b)=>a+b,0);
      const pct = raw * 4;
      const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
      await sb.from('mood_logs').insert([{ user_id: null, date: v.date, who5_raw: raw, who5_pct: pct }]);
      return new Response(JSON.stringify({ ok: true, raw, pct }), { headers: { 'content-type': 'application/json' } });
    }
    return new Response(JSON.stringify({ error: 'method not allowed' }), { status: 405 });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
