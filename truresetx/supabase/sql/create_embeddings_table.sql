-- Run this in your Supabase SQL editor to create a documents table for RAG
-- Requires the pgvector extension (run: CREATE EXTENSION IF NOT EXISTS vector;)

CREATE TABLE IF NOT EXISTS documents (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  metadata JSONB,
  embedding vector(1536),
  created_at timestamptz DEFAULT now()
);

-- Example index using ivfflat (requires pgvector >= install with ivfflat support)
CREATE INDEX IF NOT EXISTS documents_embedding_idx ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- RPC helper: returns the top-k nearest neighbors by vector distance
CREATE OR REPLACE FUNCTION match_documents(query_embedding float8[], match_count int)
RETURNS TABLE(id TEXT, content TEXT, metadata JSONB, distance double precision) AS $$
BEGIN
  RETURN QUERY
  SELECT id, content, metadata, (embedding <-> query_embedding) as distance
  FROM documents
  ORDER BY embedding <-> query_embedding
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql;
