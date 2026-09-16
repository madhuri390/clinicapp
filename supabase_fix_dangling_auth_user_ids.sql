-- Clear patients.auth_user_id where it points at an auth account that does not
-- exist.
--
-- The data migration filled auth_user_id with each patient's OWN row id,
-- naming login accounts that were never created (474 of 479 rows are
-- self-referential). The patient form read that pointer, took it for a real
-- account, and called the Auth admin API to update it — which 404s. Because
-- the Auth call ran before the database write, the whole save aborted and the
-- edit was lost. That is why ~211 patients could not have their name corrected.
--
-- Run this in the Supabase SQL editor. It is idempotent.

BEGIN;

-- 1. Snapshot the rows about to change, so the exact prior values survive.
CREATE TABLE IF NOT EXISTS public.patients_auth_link_backup (
  patient_id   uuid PRIMARY KEY,
  auth_user_id uuid NOT NULL,
  first_name   text,
  last_name    text,
  phone        text,
  username     text,
  backed_up_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.patients_auth_link_backup
      (patient_id, auth_user_id, first_name, last_name, phone, username)
SELECT p.id, p.auth_user_id, p.first_name, p.last_name, p.phone, p.username
FROM   public.patients p
WHERE  p.auth_user_id IS NOT NULL
  AND  NOT EXISTS (SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id)
ON CONFLICT (patient_id) DO NOTHING;

-- 2. Report what is about to be cleared.
DO $$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
  FROM   public.patients p
  WHERE  p.auth_user_id IS NOT NULL
    AND  NOT EXISTS (SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id);
  RAISE NOTICE 'clearing % dangling auth_user_id value(s)', n;
END $$;

-- 3. Null them out. These patients have no login and never did; the record now
--    says so honestly, and the patient form will save edits without touching
--    the Auth system at all.
UPDATE public.patients p
SET    auth_user_id = NULL
WHERE  p.auth_user_id IS NOT NULL
  AND  NOT EXISTS (SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id);

COMMIT;

-- 4. Verify: this must return 0.
SELECT count(*) AS still_dangling
FROM   public.patients p
WHERE  p.auth_user_id IS NOT NULL
  AND  NOT EXISTS (SELECT 1 FROM auth.users u WHERE u.id = p.auth_user_id);

-- To undo:
--   UPDATE public.patients p
--   SET    auth_user_id = b.auth_user_id
--   FROM   public.patients_auth_link_backup b
--   WHERE  p.id = b.patient_id;

-- Recommended follow-up, once the count above is 0. supabase_schema.sql:101
-- declares this constraint but it is absent from the live database — which is
-- how the bogus pointers were written in the first place. Adding it makes the
-- failure impossible to repeat:
--   ALTER TABLE public.patients
--     ADD CONSTRAINT patients_auth_user_id_fkey
--     FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
