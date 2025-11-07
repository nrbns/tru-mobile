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
    const schema = z.object({ image_url: z.string().optional(), barcode: z.string().optional(), notes: z.string().optional() });
    const input = schema.parse(body);
    const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    // If barcode provided, lookup OFF or local catalog; else if image, call vision heuristics (not implemented)
    if (input.barcode) {
      const { data } = await sb.from('food_catalog').select('*').eq('external_id', input.barcode).limit(1).maybeSingle();
      if (data) return new Response(JSON.stringify({ item: data }), { headers: { 'content-type': 'application/json' } });

      // Query Open Food Facts
      const offUrl = `https://world.openfoodfacts.org/api/v0/product/${input.barcode}.json`;
      const r = await fetch(offUrl);
      if (r.ok) {
        const js = await r.json();
        if (js.status === 1 && js.product) {
          const p = js.product;
          const nutrients = (p.nutriments) ? normalizeOffNutrients(p.nutriments) : {};
          const item = {
            source: 'OFF',
            external_id: input.barcode,
            name: p.product_name || p.generic_name || 'Unknown',
            brand: p.brands || null,
            serving_qty: p.serving_size ? parseFloat((p.serving_size).replace(/[a-zA-Z]/g, '')) : null,
            serving_unit: p.serving_size ? p.serving_size.replace(/[0-9.\s]/g, '') : null,
            nutrients,
            labels: { off: true, categories: p.categories_tags },
          };

          await sb.from('food_catalog').upsert([item], { onConflict: ['source', 'external_id'] });
          return new Response(JSON.stringify({ item }), { headers: { 'content-type': 'application/json' } });
        }
      }
    }

    return new Response(JSON.stringify({ item: null }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: { 'content-type': 'application/json' } });
  }
});

function normalizeOffNutrients(n: any) {
  const out: any = {};
  if (n['energy-kcal_100g']) out.calories = Number(n['energy-kcal_100g']);
  if (n['proteins_100g']) out.protein_g = Number(n['proteins_100g']);
  if (n['carbohydrates_100g']) out.carbs_g = Number(n['carbohydrates_100g']);
  if (n['fat_100g']) out.fat_g = Number(n['fat_100g']);
  return out;
}
