generate_workout_plan Edge Function

This is a minimal Supabase Edge Function (Deno + TypeScript) to generate a 28-day workout plan using OpenAI Responses API and store it in Supabase.

Environment variables (set in Supabase dashboard or .env during local dev):
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY
- OPENAI_API_KEY

Local dev (supabase CLI):
1. Install Supabase CLI: https://supabase.com/docs/guides/cli
2. From the project root run:

   supabase functions serve generate_workout_plan --env-file supabase/functions/.env.example

API contract
- POST /generate_workout_plan
  - body: { user_id, goal, fitness_level, time_per_day_min }
  - returns: { ok: true, plan_id, plan }

Notes
- This example uses the OpenAI Responses API via the `openai` package on ESM.
- Use `zod` to validate input and reject bad requests quickly.
- Keep the function small and stateless: heavy tasks should be queued to a worker/orchestrator.
