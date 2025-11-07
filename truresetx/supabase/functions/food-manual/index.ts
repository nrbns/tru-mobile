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
    const schema = z.object({ name: z.string(), serving_qty: z.number(), serving_unit: z.string(), nutrients: z.any() });
    const input = schema.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { error, data } = await sb.from('food_catalog').insert([{ source: 'MANUAL', external_id: null, name: input.name, serving_qty: input.serving_qty, serving_unit: input.serving_unit, nutrients: input.nutrients }]).select().maybeSingle();
    if (error) throw error;
    return new Response(JSON.stringify({ item: data }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'content-type': 'application/json' } });
  }
});
