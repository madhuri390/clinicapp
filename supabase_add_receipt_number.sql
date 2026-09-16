-- Receipt/bill number, stamped on a visit when it is marked complete.
--
-- Format: YYYYMMDD-NN, where NN is the sequence among visits completed that
-- same day (01, 02, ...). Assigned once and never regenerated, so reprinting
-- a bill always shows the same number. Only newly created visits get one —
-- existing/historical visits are left NULL, not backfilled.
ALTER TABLE public.visits
ADD COLUMN IF NOT EXISTS receipt_number text;

DO $$ BEGIN
  ALTER TABLE public.visits
  ADD CONSTRAINT visits_receipt_number_unique UNIQUE (receipt_number);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

COMMENT ON COLUMN public.visits.receipt_number IS
  'Bill/receipt number assigned once the visit is marked complete. Format YYYYMMDD-NN.';
