-- Treatment advised / planned, captured at consultation time.
--
-- Distinct from the treatment_plans rows: those are the costed, scheduled
-- treatments added afterwards. This is what the doctor recommended during the
-- visit itself, in their own words, and is what the Ongoing/History tabs and
-- the patient list surface at a glance.
ALTER TABLE public.visits
ADD COLUMN IF NOT EXISTS treatment_advised text;

COMMENT ON COLUMN public.visits.treatment_advised IS
  'Free-text treatment advised/planned recorded during the consultation.';
