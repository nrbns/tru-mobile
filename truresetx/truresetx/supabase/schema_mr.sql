-- Motivation & Resilience (MR) Schema for Supabase
-- Tables: mr_events, mr_protocols, mr_incidents, mr_daily

create type if not exists public.mr_protocol_kind as enum ('grounding','breath','anger_reset','boundary_script','no_contact','agent_call','boss_debrief','incident_log','walk_reset','journal_reframe','finance_action');

create table if not exists public.mr_events (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  kind text,
  intensity int,
  note text,
  recorded_at timestamptz default now(),
  created_at timestamptz default now()
);

alter table public.mr_events enable row level security;
create policy "own mr_events" on public.mr_events for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.mr_protocols (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  event_id bigint references public.mr_events(id) on delete set null,
  kind public.mr_protocol_kind not null,
  payload jsonb not null,
  minutes int,
  relief_delta int,
  completed boolean default false,
  created_at timestamptz default now(),
  completed_at timestamptz
);

alter table public.mr_protocols enable row level security;
create policy "own mr_protocols" on public.mr_protocols for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.mr_incidents (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  source text check (source in ('voice','text','photo','video','mix')),
  description text,
  location text,
  tags text[],
  recorded_at timestamptz default now(),
  created_at timestamptz default now()
);

alter table public.mr_incidents enable row level security;
create policy "own mr_incidents" on public.mr_incidents for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.mr_daily (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  day_date date not null,
  events int default 0,
  avg_intensity numeric(4,2),
  protocols_done int default 0,
  relief_avg numeric(4,2),
  anger_events int default 0,
  debt_actions int default 0,
  resilience_score int,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, day_date)
);

alter table public.mr_daily enable row level security;
create policy "own mr_daily" on public.mr_daily for select using (auth.uid() = user_id);

create or replace function public.mr_recompute_daily(user_uuid uuid, d date)
returns void language plpgsql as $$
begin
  insert into public.mr_daily as md (
    user_id, day_date, events, avg_intensity, protocols_done, relief_avg, anger_events, debt_actions, resilience_score, updated_at)
  select user_uuid, d,
    (select count(*) from public.mr_events e where e.user_id=user_uuid and e.recorded_at::date=d),
    (select round(avg(intensity),2) from public.mr_events e where e.user_id=user_uuid and e.recorded_at::date=d),
    (select count(*) from public.mr_protocols p where p.user_id=user_uuid and coalesce(p.completed_at,p.created_at)::date=d),
    (select round(avg(relief_delta),2) from public.mr_protocols p where p.user_id=user_uuid and coalesce(p.completed_at,p.created_at)::date=d),
    (select count(*) from public.mr_events e where e.user_id=user_uuid and e.kind='anger_surge' and e.recorded_at::date=d),
    (select count(*) from public.mr_protocols p where p.user_id=user_uuid and p.kind='finance_action' and coalesce(p.completed_at,p.created_at)::date=d),
    greatest(0, least(100,
      60
      - coalesce(((select avg(intensity) from public.mr_events e where e.user_id=user_uuid and e.recorded_at::date=d)::int)*5,0)
      + coalesce(((select avg(relief_delta) from public.mr_protocols p where p.user_id=user_uuid and coalesce(p.completed_at,p.created_at)::date=d)::int)*6,0)
      + coalesce(((select count(*) from public.mr_protocols p where p.user_id=user_uuid and coalesce(p.completed_at,p.created_at)::date=d))*2,0)
      - coalesce(((select count(*) from public.mr_events e where e.user_id=user_uuid and e.kind='anger_surge' and e.recorded_at::date=d))*3,0)
    )),
    now())
  on conflict (user_id, day_date) do update set
    events=excluded.events,
    avg_intensity=excluded.avg_intensity,
    protocols_done=excluded.protocols_done,
    relief_avg=excluded.relief_avg,
    anger_events=excluded.anger_events,
    debt_actions=excluded.debt_actions,
    resilience_score=excluded.resilience_score,
    updated_at=now();
end;$$;

create or replace function public.mr_after_change_recompute()
returns trigger language plpgsql as $$
begin
  perform public.mr_recompute_daily(new.user_id, (coalesce(new.recorded_at, new.completed_at, new.created_at, now()))::date);
  return null;
end;$$;

-- Note: triggers above reference tables not yet created (mr_events/mr_protocols triggers should be created when both tables exist). Add triggers after creating mr_events/mr_protocols.
