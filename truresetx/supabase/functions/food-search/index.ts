/* eslint-disable */
declare const Deno: any;
// Supabase Edge Function: /food/search?q=...&locale=in
// Minimal implementation: search local catalog, fallback to USDA (pseudo)
// NOTE: configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in env
// Deploy with `supabase functions deploy food-search` or via the Supabase CLI
// This is a stub: replace USDA fetch/normalization with production code.

// @ts-ignore: remote import for Deno runtime
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore: remote import for Deno runtime
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore: remote import for Deno runtime
import { z } from "https://esm.sh/zod@3";

const qSchema = z.object({ q: z.string().min(1), locale: z.string().optional() });

serve(async (req: Request) => {
  try {
    const url = new URL(req.url);
    const q = url.searchParams.get('q') ?? '';
    const locale = url.searchParams.get('locale') ?? 'en';
    const parsed = qSchema.parse({ q, locale });

    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    const { data: hits } = await sb.from('food_catalog').select('*').ilike('name', `%${parsed.q}%`).limit(20);
    if (hits && hits.length) {
      return new Response(JSON.stringify({ items: hits }), { headers: { 'content-type': 'application/json' } });
    }

    // 2) fallback to USDA FoodData Central
    const usdaKey = Deno.env.get('USDA_API_KEY');
    if (usdaKey) {
      const r = await fetch(`https://api.nal.usda.gov/fdc/v1/foods/search?query=${encodeURIComponent(parsed.q)}&pageSize=10&api_key=${usdaKey}`);
      if (r.ok) {
        const js = await r.json();
        const items = (js.foods || []).map((f: any) => ({
          name: f.description,
          source: 'USDA',
          external_id: String(f.fdcId),
          serving_qty: f.servingSize || null,
          serving_unit: f.servingSizeUnit || 'g',
          nutrients: normalizeUsdaNutrients(f.foodNutrients || []),
        }));

        // Upsert into catalog
        for (const it of items) {
          await sb.from('food_catalog').upsert([{ source: 'USDA', external_id: it.external_id, name: it.name, serving_qty: it.serving_qty, serving_unit: it.serving_unit, nutrients: it.nutrients }], { onConflict: ['source', 'external_id'] });
        }

        return new Response(JSON.stringify({ items }), { headers: { 'content-type': 'application/json' } });
      }
    }

    return new Response(JSON.stringify({ items: [] }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'content-type': 'application/json' } });
  }
});

function normalizeUsdaNutrients(arr: any[]) {
  const out: any = {};
  for (const n of arr) {
    const name = (n.nutrient && n.nutrient.name) || n.nutrientName || n.name;
    const value = n.amount ?? n.value ?? n.valueInGrams ?? null;
    if (!name || value == null) continue;
    const key = mapNutrientName(name);
    if (key) out[key] = Number(value);
  }
  return out;
}

function mapNutrientName(n: string) {
  const s = n.toLowerCase();
  if (s.includes('energy') || s.includes('kcal')) return 'calories';
  if (s.includes('protein')) return 'protein_g';
  if (s.includes('carbohydrate')) return 'carbs_g';
  if (s.includes('fat')) return 'fat_g';
  return null;
}
