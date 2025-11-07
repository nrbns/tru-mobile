# TruResetX — First-User MVP Plan & Real‑Time Journey

**Owner:** Narene Babu

**Date:** Oct 27, 2025

## Goal
Ship a usable, real‑time MVP you (Narene) can use daily, showcase publicly, and iterate fast.

## 1) North Star & Success Metrics

**North Star:** Daily Active Use (YOU) + visible progress logs shared weekly.

**90‑Day Outcome:** −30 to −40 kg target (from 120 kg). Visible abs plan + discipline scores.

### MVP Success Metrics (Week 1–4)
- D1: Complete onboarding, baseline body stats, first workout + first meal logged.
- D3: ≥12 discipline actions logged; streak ≥3 days.
- D7: Weight logs on ≥4 days; mood on ≥5 days; >2 AI coach chats.
- Share 1 public progress card by end of Week 1.

## 2) First‑User Feature Set (Scope for MVP)

A. Real‑Time Tracking (core)
- Vitals: Weight, body fat (manual), waist, BP (optional), sleep hours.
- Workouts: Plan vs actual, sets/reps/time; import from templates; timer.
- Meals: Quick add (camera OCR later), macros estimates, favorites.
- Discipline: Habits (wake up, no sugar, meditation, study), streaks.
- Mood & Energy: 1–5 slider, tags, notes.
- Notes/Journal: Markdown; auto‑timestamp; AI summary.

B. AI Coach (narrow, useful)
- Daily Plan: Based on weight trend + calendar + discipline score.
- Check‑ins: Morning (plan), Evening (review), Red‑flag alerts (missed logs).
- Micro‑prompts: “Swap choice” nudges during meal/workout.

C. Spiritual Mode / Non‑spiritual Mode
- Toggle at onboarding.
- Spiritual path: meditation, mantra reps, Vedic knowledge micro‑cards, Parashurama path (Vedas/Tantra/weapon mastery learning tracker).
- Non‑spiritual path: Stoic prompts, focus blocks, worldly self‑mastery tasks.

D. Social/Share (lightweight)
- Public Progress Card: Auto‑generated weekly share image with key stats.
- Live Journey Page (optional, private link): Read‑only, updating in real time.

E. Admin/Founder Tools (for you)
- Data Editor: Fix logs quickly.
- Experiment Flags: Toggle features live (A/B your own routine).
- Export: CSV/JSON for all logs at any time.

## 3) Real‑Time System Design (MVP, pragmatic)

**Stack (suggested):**
- Frontend: React (Next.js), Tailwind, shadcn/ui; PWA + offline cache.
- Auth: Email magic link + device pin; optional Google/Apple.
- DB + Realtime: Supabase (Postgres + Realtime channels) or Firebase (Firestore + onSnapshot). Choose one.
- Edge Functions: Validation + derived metrics (discipline_score, TDEE est).
- File Storage: Supabase Storage or Firebase Storage for photos.
- AI: OpenAI API (coach prompts & summaries).
- Analytics: PostHog (self‑host optional) events.

**Realtime Patterns:**
- Event Sourcing-lite: Append‑only events table; reducers compute views.
- Optimistic UI: Write local → show immediate → reconcile on ack.
- Conflict Strategy: Last‑writer‑wins per field; journal uses per‑paragraph merge.

**Offline‑first:**
- Service worker caches shell; IndexedDB mirrors last 30 days; queue unsynced ops.

## 4) Data Model (initial)

Short schema sketch (Postgres/Supabase):

- users: id uuid pk, display_name text, mode text check(mode in ('spiritual','worldly')), height_cm int, dob date, created_at timestamptz
- metrics_weight: id uuid pk, user_id uuid fk, kg numeric(5,2), body_fat numeric(4,1) null, waist_cm int null, recorded_at timestamptz, source text default 'manual'
- workouts: id uuid pk, user_id uuid fk, plan jsonb, actual jsonb, started_at, ended_at, notes text
- meals: id uuid pk, user_id uuid fk, title text, photo_url text null, kcal int, protein_g int, carbs_g int, fat_g int, recorded_at timestamptz
- habits: id uuid pk, user_id uuid fk, name text, target_per_day int default 1, active bool default true
- habit_logs: id uuid pk, habit_id uuid fk, count int default 1, logged_at timestamptz
- mood_logs: id uuid pk, user_id uuid fk, mood int check (mood between 1 and 5), energy int check (energy between 1 and 5), tags text[], note text, logged_at timestamptz
- journal: id uuid pk, user_id uuid fk, content markdown, created_at timestamptz
- events (for realtime streaming): seq bigserial pk, user_id uuid fk, type text, payload jsonb, created_at timestamptz
- derived_views (materialized views refreshed by triggers): user_daily_summary (date, weight, kcal, protein, workout_minutes, discipline_score)

**Derived Metric: discipline_score (0–100)**
- Weight log today (+10), workout (+20), ≥100g protein (+15), hit all core habits (+20), no sugar (+10), ≥7h sleep (+10), journal (+5), meditation/prayer or focus block (+10).

## 5) Key Screens & Flows

**Onboarding (3 min)**
- Choose mode: Spiritual / Worldly
- Baseline: height, current weight, photos (front/side), sleep avg
- Goals: target weight & deadline (90 days), injuries (optional)
- Daily window: wake time, workout slot, meals/day
- Consent: private share link toggle

**Home (Realtime Dashboard)**
- Today card: weight, kcal, protein, workout minutes, discipline score, streak.
- Quick actions: +Weight, +Meal, +Workout, +Habit, +Mood, +Note.

**Coach**
- Morning plan (auto at 6–8 AM) + checkboxes.
- Red‑flag alerts if weight ↑ 3 days or streak broken.
- Evening review with summary & next‑day adjustments.

**Loggers**
- Meal: quick presets, last used, “protein priority” tips.
- Workout: timers, RPE, templates (push/pull/legs; cardio; HIIT).
- Habit: tap to increment; streak animation.

**Share**
- Weekly progress image; private live page.

## 6) Implementation Plan (10‑Day Sprint)

- Day 0 (today): Create repo, choose DB (Supabase recommended), scaffold Next.js, auth, shadcn/ui, Tailwind, PostHog.
- Day 1: Data schema + auth + Realtime channel; Home dashboard mock.
- Day 2: Weight + meal logger (offline + optimistic).
- Day 3: Workout logger + timers; discipline score function.
- Day 4: Habits + streaks; mood log.
- Day 5: Coach v0 (morning/evening prompts), summaries; weekly share image.
- Day 6: Public live page (read‑only) + export CSV.
- Day 7: Spiritual/worldly toggle paths; micro‑cards.
- Day 8: PWA offline, installable; error states.
- Day 9: QA with your real data; fix; performance.
- Day 10: Soft launch (you), publish first weekly card.

## 7) API/Edge Functions (examples)

POST /api/weight { kg, bodyFat?, waist?, at }
POST /api/meal { title, kcal, protein_g, carbs_g, fat_g, photo? }
POST /api/workout/start { templateId? }
POST /api/workout/end { actual }
POST /api/habit/{id}/tick
POST /api/mood { mood, energy, tags?, note? }
GET  /api/summary/today
GET  /api/share/weekly-card.png

Realtime channel: realtime:user:{userId} emits compact events: {type, payload, ts}

Security: RLS/Rules: user can only access their rows; public page uses server-rendered tokens.

## 8) Coach Prompting (initial system)

**Morning Plan Prompt (inputs):** yesterday summary, trend(7d), today calendar, discipline gaps.
**Output:** checklist of 5–7 items: wake‑up time, workout plan, protein targets, hydration, forbidden food, meditation/focus block.

**Evening Review Prompt (inputs):** today logs.
**Output:** 3 wins, 1 correction, plan for tomorrow.

## 9) UI Components (shadcn/ui set)

- Cards: Today, Weight, Meals, Workout, Habits, Mood, Journal.
- Dialogs: Quick Add forms.
- Charts: 7‑day weight line; discipline bar; calories line.
- Badge: Streaks.
- Button: Share Weekly Card.

## 10) Founder Ops & Growth

- Public Build‑in‑Open: post weekly progress card + learning thread.
- Community: private link for friends to cheer.
- Data Hygiene: daily backup, export weekly.

## 11) Backlog (prioritized)

**P1 (must):**
- Weight/Meal/Workout/Habit/Mood loggers
- Realtime dashboard + optimistic writes
- Discipline score + streaks
- Morning/Evening coach
- Weekly share card + live page
- Export + privacy controls

**P2 (next):**
- Camera OCR for meals, barcode scan
- BP/sleep integrations (Apple Health/Google Fit)
- Photo pose standardizer
- Coach “plateaus” protocol
- Challenge Mode (30‑day extreme) with guardrails

**P3 (later):**
- Friends leaderboard
- Templates marketplace
- Multi‑user coach
- Wearables; HRV
- Nutrition auto‑plan with pantry constraints

## 12) Deliverables Checklist

(Keep this as the living checklist inside the PRD.)

## 13) Demo Script (for showcase)

1. Log weight → watch Today card update in realtime.
2. Start workout timer → complete → discipline score jumps.
3. Add meal with photo → protein tally updates.
4. Tick habits → streak animation.
5. Generate weekly card → share link opens live page.

## 14) Risks & Mitigations

- Over‑scope: Stick to P1; defer OCR/integrations.
- Data loss: daily backups; export anytime.
- Motivation dips: coach red‑flags + community cheers.
- Performance: pagination (30‑day window), IndexedDB cache.

## 15) Your Day‑0 Tasks (actionable)

1. Choose DB: Supabase (recommended) vs Firebase.
2. Create project & env keys; set RLS; run schema.
3. Scaffold Next.js app, Tailwind, shadcn/ui, PostHog.
4. Implement Weight logger first + Today card.
5. Start logging today.

---

This document is the living PRD for the TruResetX First‑User MVP. We can iterate it inside the repo; tell me if you want me to:

- Create issues for the P1 items,
- Scaffold the Weight logger + Today card in the Flutter app (or Next.js frontend), or
- Add a demo screen in Flutter to surface the Firestore realtime providers.
