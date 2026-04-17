-- ═══════════════════════════════════════════════════════════════════════════
-- Patient signup RLS fix — run in Supabase SQL Editor if you see:
--   "new row violates row-level security policy" on INSERT into public.patients
--
-- Typical causes:
--   1) No policy allows INSERT for role `authenticated` (only SELECT exists).
--   2) Client had no JWT (signUp with "Confirm email" ON → session null → anon role).
--      Fix in app: session established before insert; and/or disable confirm email for dev.
-- ═══════════════════════════════════════════════════════════════════════════

-- Allow any signed-in user to insert a patient row (staff + self-registration).
-- If you already have an equivalent policy (e.g. "staff_all"), this is redundant but safe.
drop policy if exists "patients_insert_authenticated" on public.patients;
create policy "patients_insert_authenticated"
  on public.patients
  for insert
  to authenticated
  with check (true);

-- Patients can update their own profile (optional, for onboarding edits).
drop policy if exists "patients_update_own" on public.patients;
create policy "patients_update_own"
  on public.patients
  for update
  to authenticated
  using (auth_user_id = auth.uid() or id = auth.uid())
  with check (auth_user_id = auth.uid() or id = auth.uid());
