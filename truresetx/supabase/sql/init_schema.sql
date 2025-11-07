-- Initial schema for TruResetX
-- FOOD & NUTRITION
create table if not exists food_catalog (
  id bigint generated always as identity primary key,
  source text not null check (source in ('USDA','OFF','MANUAL')),
  external_id text,
  name text not null,
  brand text,
  serving_qty numeric,
  serving_unit text,
  nutrients jsonb,
  labels jsonb,
  lang text default 'en',
  updated_at timestamptz default now(),
  unique(source, external_id)
);

create table if not exists food_logs (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  logged_at timestamptz not null,
  food_id bigint references food_catalog(id),
  source text check (source in ('SCAN','BARCODE','MANUAL')),
  image_url text,
  quantity numeric not null,
  overrides jsonb,
  totals jsonb,
  created_at timestamptz default now()
);

-- WORKOUTS & AR
create table if not exists exercises (
  id bigserial primary key,
  name text unique not null,
  primary_muscle text,
  secondary_muscles text[],
  equipment text[],
  video_url text,
  cues text[],
  ar_err_rules jsonb
);

create table if not exists workouts (
  id bigserial primary key,
  user_id uuid references auth.users(id),
  date date,
  title text,
  plan_json jsonb
);

create table if not exists sets_logs (
  id bigserial primary key,
  workout_id bigint references workouts(id) on delete cascade,
  exercise_id bigint references exercises(id),
  set_no int,
  reps int,
  rep_metrics jsonb,
  ar_scores jsonb,
  pain_flag boolean default false
);

-- MOOD & WELLNESS
create table if not exists mood_logs (
  id bigserial primary key,
  user_id uuid references auth.users(id),
  date date,
  who5_raw int,
  who5_pct int,
  energy int,
  stress int,
  notes text
);

-- SPIRITUAL & WISDOM
create table if not exists scripture_sources (
  id bigserial primary key,
  tradition text,
  work text,
  lang text,
  license text
);

create table if not exists scripture_verses (
  id bigserial primary key,
  source_id bigint references scripture_sources(id),
  chapter int,
  verse int,
  text_original text,
  text_translation text,
  audio_url text
);

create table if not exists wisdom_items (
  id bigserial primary key,
  category text,
  title text,
  body text,
  duration_min int,
  ambiance jsonb
);

-- Optional pgvector setup and indices can be added later
