-- Add missing columns used by the app UI + Rx PDF generator.
-- Run this in Supabase SQL editor (or your migrations pipeline).

-- 1) Prescriptions: duration (if your table was created without it)
alter table public.prescriptions
  add column if not exists duration text;

-- 2) Treatment plans: teeth numbers (FDI, e.g. '16, 18' or '25')
alter table public.treatment_plans
  add column if not exists teeth text;

