TruResetX Supabase Edge Functions

This folder contains Deno TypeScript Edge Function stubs for the TruResetX backend API.

Deployment
- Install supabase CLI and authenticate.
- Set environment variables in your Supabase project: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, USDA_API_KEY, OPENAI_API_KEY (if used).
- Deploy a function:
  supabase functions deploy food-search --project-ref <your-ref>

Notes
- These functions are minimal stubs and need production logic to fetch and normalize USDA / Open Food Facts data.
- Ensure you respect third-party licensing (Open Food Facts ODbL attribution, USDA CC0) when storing and serving data.

Env required
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY
- USDA_API_KEY (for USDA lookups)
- OPENAI_API_KEY (if you add embedding/AI steps)

Endpoints added (stubs):
- GET /food/search?q=...       -> searches local catalog, falls back to USDA
- POST /food/scan             -> accepts {image_url, barcode, notes} and returns canonical item
- POST /food/log              -> logs a food entry and computes totals
- POST /food/manual           -> create a manual food entry
- GET /food/day?date=YYYY-MM-DD -> returns logs and totals for a day

- GET /exercises?muscle=...   -> list exercises
- POST /workouts/start-set    -> returns AR targets for an exercise
- POST /workouts/rep          -> submit per-rep metrics (logs and scoring)
- POST /workouts/end-set      -> aggregate and return suggestions

- POST /mood/who5             -> submit WHO-5 answers
- GET /mood/summary?week=...  -> weekly mood summary

- GET /spiritual/gita/verse?chapter=&verse=&lang=&lang= -> get verse
- GET /wisdom/daily           -> get daily wisdom item

Notes:
- Open Food Facts (OFF) attribution required if you store or re-publish their data. Keep an attribution string in your UI when showing OFF-origin data.
- USDA FoodData Central requires API key; data is CC0.

