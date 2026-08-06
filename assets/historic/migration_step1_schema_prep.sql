-- =============================================================
-- MIGRATION STEP 1: SCHEMA PREP
-- Run this FIRST in Supabase SQL Editor
-- Safe to re-run (uses IF NOT EXISTS / IF EXISTS)
-- =============================================================

-- Add legacy_patient_code to preserve historical PRODONT codes
ALTER TABLE public.patients
  ADD COLUMN IF NOT EXISTS legacy_patient_code TEXT;

-- Unique index (allows null, only enforces uniqueness on non-null values)
CREATE UNIQUE INDEX IF NOT EXISTS patients_legacy_patient_code_idx
  ON public.patients (legacy_patient_code)
  WHERE legacy_patient_code IS NOT NULL;

-- Verify
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'patients'
  AND column_name = 'legacy_patient_code';

