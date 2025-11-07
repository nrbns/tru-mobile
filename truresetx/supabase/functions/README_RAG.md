RAG (Retrieval-Augmented Generation) support

This repo includes a minimal RAG pipeline that uses Supabase (pgvector) to store document embeddings and a Supabase Edge Function to query nearby documents.

Files added:
- `supabase/sql/create_embeddings_table.sql` - SQL to create `documents` table and a match_documents RPC function.
- `tools/ingest_embeddings.ts` - Node script to embed and insert documents into Supabase.
- `supabase/functions/query_rag/index.ts` - Edge Function to generate a query embedding and call `match_documents` RPC.

How to set up
1. Enable pgvector in your Supabase DB:
   - Run: `CREATE EXTENSION IF NOT EXISTS vector;`
2. Run the SQL in `supabase/sql/create_embeddings_table.sql` in the Supabase SQL editor.
3. Ingest documents:
   - Set env vars: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `OPENAI_API_KEY`
   - If you have embeddings exported from Colab (JSON array of {id,content,embedding,metadata}) you can use the Deno bulk importer:

     deno run --allow-env --allow-read --allow-net tools/ingest_embeddings_deno.ts path/to/embeddings.json

   - Or use the Node-based script:

     cd tools
     npm install
     npm run ingest -- <file-or-dir>

   - To start the socket server for realtime testing:

     cd tools
     npm install
     npm run socket
4. Deploy `query_rag` as an Edge Function and call it with a JSON body `{ "query":"your question", "k":5 }`.

Local test socket server
- `tools/socket_server.js` runs a Socket.IO server on port 3000 for testing the Realtime Loader.
  - Usage: `node tools/socket_server.js`
  - The loader will connect to `http://localhost:3000` or, for Android emulator, `http://10.0.2.2:3000`.

Notes
- The ingestion script is a minimal example. For large-scale ingestion, chunk documents, handle rate limits, and store metadata (source, section, timestamps).
- Edge Functions run on Deno in Supabase; ensure env vars are configured in the dashboard.

CI / Deployment notes
- A sample `fastlane` configuration and GitHub Actions workflow are included at `fastlane/` and `.github/workflows/android-deploy.yml`.
- You must add `PLAY_STORE_JSON` secret to GitHub (service account JSON) for CI to upload to Play Console.
