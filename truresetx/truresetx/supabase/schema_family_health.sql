-- TruResetX — Family Health Schema & Realtime API (Diabetes + PCOS)
-- Use this SQL as a reference migration for Supabase/Postgres. Review RLS and env before applying.

-- Profiles table
create table if not exists public.profile (
  user_id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  tz text default 'Asia/Kolkata',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profile enable row level security;
create policy "Own profile read" on public.profile
  for select using (auth.uid() = user_id);
create policy "Own profile upsert" on public.profile
  for insert with check (auth.uid() = user_id);
create policy "Own profile update" on public.profile
  for update using (auth.uid() = user_id);

-- Health focus type enum and health_profile
create type if not exists public.health_focus_type as enum ('general','diabetic','pcos');

create table if not exists public.health_profile (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  focus public.health_focus_type not null default 'general'
);

alter table public.health_profile enable row level security;
create policy "Own health profile" on public.health_profile
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Daily aggregates (summary) — example
create table if not exists public.daily_aggregates (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  day_date date not null,
  avg_glucose numeric(6,2),
  sleep_min int,
  mood_avg numeric(4,2),
  stress_avg numeric(4,2),
  activity_min int,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, day_date)
);

alter table public.daily_aggregates enable row level security;
create policy "Own daily aggregates" on public.daily_aggregates
  for select using (auth.uid() = user_id);

-- NOTE: Add the rest of the tables and triggers in subsequent migrations (measurements_glucose, meals, mood_logs, sleep_sessions, cycle_logs, recommendations, etc.)
