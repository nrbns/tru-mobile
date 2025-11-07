// Minimal Node script to ingest text files into Supabase with embeddings
// Usage: NODE_ENV=development node tools/ingest_embeddings.ts <file-or-folder>

import fs from 'fs';
import path from 'path';
import OpenAI from 'openai';
import { createClient } from '@supabase/supabase-js';

// CLI: node ingest_embeddings.ts <file-or-dir> [--dry-run]

const DRY_RUN = process.argv.includes('--dry-run');

const SUPABASE_URL = process.env.SUPABASE_URL || '';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
const OPENAI_KEY = process.env.OPENAI_API_KEY || '';

let supabase: ReturnType<typeof createClient> | null = null;
let openai: OpenAI | null = null;

if (!DRY_RUN) {
  if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.warn('Supabase URL or Service Role key not provided. Falling back to --dry-run mode.');
  } else {
    supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
  }

  if (!OPENAI_KEY) {
    console.warn('OPENAI_API_KEY not provided. Falling back to --dry-run mode.');
  } else {
    openai = new OpenAI({ apiKey: OPENAI_KEY });
  }
}

async function embedText(text: string) {
  if (!openai) {
    // create a dummy embedding when openai key missing
    const fake = new Array(1536).fill(0).map((_, i) => Math.sin(i + text.length));
    return fake;
  }
  const r = await openai.embeddings.create({ model: 'text-embedding-3-small', input: text });
  // @ts-ignore - ensure runtime access
  return r.data[0].embedding;
}

async function ingestFile(filePath: string) {
  const content = fs.readFileSync(filePath, 'utf8');
  const embedding = await embedText(content);
  const id = path.basename(filePath) + '-' + Date.now();

  if (DRY_RUN || !supabase) {
    // Use the script directory so running from different CWDs doesn't duplicate paths
    const outDir = path.join(__dirname, 'ingest-output');
    if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
    const outPath = path.join(outDir, `${id}.json`);
    fs.writeFileSync(outPath, JSON.stringify({ id, content, metadata: { source: filePath }, embedding }, null, 2), 'utf8');
    console.log('[dry-run] Wrote', outPath);
    return;
  }

  // supabase-js client generics can be strict in TS projects; cast to any for tooling scripts
  const { error } = await (supabase as any).from('documents').insert([{ id, content, metadata: { source: filePath }, embedding }]);
  if (error) console.error('Insert error', error);
  else console.log('Inserted', id);
}

async function main() {
  const args = process.argv.filter(a => a !== '--dry-run');
  const target = args[2];
  if (!target) {
    console.error('usage: node tools/ingest_embeddings.js <file-or-dir> [--dry-run]');
    process.exit(1);
  }

  const stat = fs.statSync(target);
  if (stat.isDirectory()) {
    const files = fs.readdirSync(target);
    for (const f of files) {
      const full = path.join(target, f);
      const s = fs.statSync(full);
      if (s.isFile()) await ingestFile(full);
    }
  } else {
    await ingestFile(target);
  }
}

main().catch(err => {
  console.error('Fatal error', err);
  process.exit(1);
});
