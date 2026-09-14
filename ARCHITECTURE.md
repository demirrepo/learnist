# Learnist Mobile App - System Blueprint

## Project Overview
An AI-driven EdTech mobile application built in Flutter with a Supabase backend, engineered for Uzbek university students preparing for CEFR certification. Features 52 structured topics across 5 skill dimensions.

## Technical Stack & Architecture
- **Frontend:** Flutter (State Management: Riverpod, Navigation: `go_router`)
- **Backend:** Supabase (Auth, PostgreSQL Database, Storage)
- **AI Integrations:** Python/Railway middleware or direct API for Socratic feedback & prompt grading

## Core Rules & Feature Requirements

### 1. Authentication & Onboarding
- Sign up via Supabase Auth (Email & Password).
- User profile creation requires: Full Name, Username, and **University**.
- **University Input Requirement:** Must use a searchable dropdown populated from `lib/constants/universities.dart`. Includes a fallback text input when "Boshqa / Other" is selected.

### 2. Main Navigation Shell (Bottom Navigation)
- **Bosh Sahifa (Home):** Header banner, carousel learning space, progress snapshot, top bar with language picker, group login, and active CEFR badge.
- **Topics (Mavzular - 52 total):**
  - Unlock Progression: Sequential unlocking (only current/unlocked lessons are active; future ones are locked).
  - Search bar filter.
  - Topic Detail Screen containing 5 sub-tabs: **Grammar, Reading, Listening, Writing, Speaking**.
  - Each sub-tab features a dedicated menu, a "Check My Result" button, and an "Ask AI" floating trigger.
- **AI Laboratory (AI Laboratoriyasi):**
  - Instructional block for writing effective AI prompts.
  - Interactive Prompt Checker providing real-time quality evaluation.
  - Step-by-step prompt optimization guide.
- **Daraja Tekshiruvi (CEFR Level Check):**
  - Diagnostic level overview and measurement history.
  - **Strict Limit:** Checkup tests can only be taken **once every 10 days**.
- **Error Map (Xatolar Xaritasi):**
  - Identifies weak areas and common test mistakes.
  - Redirects students directly to specific topics needing reinforcement.
- **Profile (Profil):**
  - Student metadata (Name, Username, Student title, CEFR level, Sign Out).
  - Metrics: Mastered topics count, joined groups count, checkup history.

### 3. Practice Test Scoring Logic
- **Aggregate Scoring Only:** Quiz results must only display total correct/incorrect counts (e.g., "Correct: 8 | Incorrect: 2 | Score: 80%").
- **Security:** DO NOT highlight specific correct/incorrect answers on the UI to prevent brute-force retakes.

### 4. Supabase Database Schema
- `profiles`: `id` (uuid, references auth.users), `full_name`, `username`, `university`, `cefr_level`, `last_cefr_check_date`, `created_at`
- `topics`: `id`, `title`, `order_index`, `semester`, `is_unlocked_by_default`
- `user_progress`: `user_id`, `topic_id`, `is_completed`, `score`
- `test_attempts`: `id`, `user_id`, `topic_id`, `correct_count`, `total_count`, `created_at`