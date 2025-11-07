/* eslint-disable */
declare const Deno: any;
// @ts-ignore: remote import used at runtime in Deno
import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
// @ts-ignore: remote import used at runtime in Deno
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore: remote import used at runtime in Deno
import OpenAI from "https://esm.sh/openai@4";
// @ts-ignore: remote import used at runtime in Deno
import { z } from "https://esm.sh/zod@3";

const schema = z.object({
  query: z.string().min(1),
  k: z.number().int().min(1).max(20).optional(),
});

serve(async (req: Request) => {
  try {
    const body = await req.json();
    const input = schema.parse(body);
    const k = input.k ?? 5;

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const OPENAI_KEY = Deno.env.get("OPENAI_API_KEY")!;

    const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
    const openai = new OpenAI({ apiKey: OPENAI_KEY });

    // Create embedding for query
    const embRes = await openai.embeddings.create({ model: 'text-embedding-3-small', input: input.query });
    const qemb = embRes.data[0].embedding;

    // Call PostgreSQL function match_documents
    const { data, error } = await supabase.rpc('match_documents', { query_embedding: qemb, match_count: k });
    if (error) throw error;

    return new Response(JSON.stringify({ ok: true, hits: data }), { headers: { 'Content-Type': 'application/json' } });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), { status: 400, headers: { 'Content-Type': 'application/json' } });
  }
});
