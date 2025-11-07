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
    const schema = z.object({ food_id: z.number().int(), quantity: z.number(), logged_at: z.string().optional(), overrides: z.any().optional() });
    const input = schema.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    // Compute totals server-side for inserted log
    const { data: food } = await sb.from('food_catalog').select('id,nutrients,serving_qty,serving_unit').eq('id', input.food_id).maybeSingle();
    const qty = input.quantity;
    let totals: any = {};
    if (food?.nutrients) {
      for (const k of Object.keys(food.nutrients)) {
        const perServing = Number(food.nutrients[k] ?? 0);
        // Assume nutrients are per 100g if serving_qty missing; this is a heuristic
        totals[k] = perServing * qty;
      }
    }

    // Apply overrides (e.g., oil_g adds calories at ~9 kcal/g)
    if (input.overrides?.oil_g) {
      const oil = Number(input.overrides.oil_g);
      totals.calories = (totals.calories || 0) + oil * 9;
    }

    const { error } = await sb.from('food_logs').insert([{ user_id: null, logged_at: input.logged_at ?? new Date().toISOString(), food_id: input.food_id, source: 'SCAN', quantity: qty, overrides: input.overrides ?? null, totals }]);
    if (error) throw error;
    return new Response(JSON.stringify({ ok: true }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'content-type': 'application/json' } });
  }
});
