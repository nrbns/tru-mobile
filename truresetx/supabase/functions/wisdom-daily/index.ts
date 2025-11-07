/* eslint-disable */
declare const Deno: any;
// @ts-ignore
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  try {
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data } = await sb.from('wisdom_items').select('*').limit(1).order('id', { ascending: false });
    return new Response(JSON.stringify({ ok: true, item: data?.[0] ?? null }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
