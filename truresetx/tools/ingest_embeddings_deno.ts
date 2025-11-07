// deno-lint-ignore-file no-explicit-any
// This file is intended to run under Deno. The workspace TypeScript server may not have Deno libs
// so we provide minimal ambient declarations for IDEs.
/* eslint-disable */
declare const Deno: any;

// Deno script to bulk-insert embeddings exported from Colab
// Usage: deno run --allow-env --allow-read --allow-net tools/ingest_embeddings_deno.ts <embeddings.json>

// @ts-ignore: remote import for Deno runtime
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

(async () => {
  if (Deno.args.length < 1) {
    console.error('Usage: deno run --allow-env --allow-read --allow-net tools/ingest_embeddings_deno.ts <file.json>');
    Deno.exit(1);
  }

  const file = Deno.args[0];
  const text = await Deno.readTextFile(file);
  const items = JSON.parse(text); // expect [{id, content, embedding: [] , metadata}]

  const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
  const SUPABASE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

  for (const it of items) {
    const { id, content, embedding, metadata } = it;
    const { error } = await supabase.from('documents').insert([{ id, content, embedding, metadata }]);
    if (error) console.error('Insert error', error);
    else console.log('Inserted', id);
  }
})();
