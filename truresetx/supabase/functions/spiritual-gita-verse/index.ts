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
    const url = new URL(req.url);
    const chapter = Number(url.searchParams.get('chapter'));
    const verse = Number(url.searchParams.get('verse'));
    const lang = url.searchParams.get('lang') ?? 'en';
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data } = await sb.from('scripture_verses').select('*').eq('chapter', chapter).eq('verse', verse).limit(1).maybeSingle();
    return new Response(JSON.stringify({ ok: true, verse: data }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
