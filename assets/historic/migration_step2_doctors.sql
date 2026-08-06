-- =============================================================
-- MIGRATION STEP 2: DOCTORS
-- Run AFTER Step 1
-- 
-- Dr. Surya teja: ALREADY HAS an auth account.
--   → We locate his auth.users entry by email and upsert the doctors row.
-- Dr. RAMYA: NEW auth user to create.
--   → Creates auth.users entry + doctors row.
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- 2A. Dr. Surya teja — find his auth_user_id and upsert doctor row
-- ─────────────────────────────────────────────────────────────
-- First, verify his auth entry exists (run this to confirm):
--   SELECT id, email FROM auth.users WHERE email = 'suryadoc88@gmail.com';
--
-- If it returns a row, his auth_user_id is the `id` column value.
-- The INSERT below will upsert using that id.

INSERT INTO public.doctors (
  first_name, last_name, email, phone,
  specialisation, is_active, consulting_fee,
  location, auth_user_id,
  created_at, updated_at
)
SELECT
  'Surya teja', NULL, 'suryadoc88@gmail.com', '+919490556555',
  'General Dentist', true, 0,
  'HYDERABAD', au.id,
  now(), now()
FROM auth.users au
WHERE au.email = 'suryadoc88@gmail.com'
ON CONFLICT (email) DO UPDATE SET
  auth_user_id = EXCLUDED.auth_user_id,
  phone        = EXCLUDED.phone,
  location     = EXCLUDED.location,
  updated_at   = now();

-- ─────────────────────────────────────────────────────────────
-- 2B. Dr. RAMYA — create auth user + doctor row
-- ─────────────────────────────────────────────────────────────
DO $$
DECLARE
  v_ramya_id UUID;
  v_auth_email TEXT := 'prathigadaparamya@gmail.com';
  v_password   TEXT := '8008896416';  -- default = her phone number
BEGIN
  -- Skip if auth user already exists
  SELECT id INTO v_ramya_id
  FROM auth.users
  WHERE email = v_auth_email
  LIMIT 1;

  IF v_ramya_id IS NULL THEN
    v_ramya_id := gen_random_uuid();

    INSERT INTO auth.users (
      id, instance_id, aud, role, email,
      encrypted_password, email_confirmed_at,
      invited_at, confirmation_token, confirmation_sent_at,
      recovery_token, recovery_sent_at,
      email_change_token_new, email_change, email_change_sent_at,
      last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data,
      is_super_admin, created_at, updated_at,
      phone, phone_confirmed_at,
      phone_change, phone_change_token, phone_change_sent_at,
      email_change_token_current,
      email_change_confirm_status, banned_until,
      reauthentication_token, reauthentication_sent_at,
      is_sso_user, deleted_at
    ) VALUES (
      v_ramya_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated', 'authenticated',
      v_auth_email,
      crypt(v_password, gen_salt('bf')),
      now(), NULL, '', NULL, '', NULL, '', NULL, NULL, NULL,
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{}'::jsonb,
      false, now(), now(),
      NULL, NULL, '', '', NULL,
      '', 0, NULL, '', NULL, false, NULL
    );

    -- Create identity record (required for email/password login)
    -- provider_id = email for email/password auth; unique constraint is on (provider_id, provider)
    INSERT INTO auth.identities (
      provider_id, user_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) VALUES (
      v_auth_email,
      v_ramya_id,
      jsonb_build_object('sub', v_ramya_id::text, 'email', v_auth_email),
      'email',
      now(), now(), now()
    )
    ON CONFLICT (provider_id, provider) DO NOTHING;

    RAISE NOTICE 'Created auth user for Dr. RAMYA: %', v_ramya_id;
  ELSE
    RAISE NOTICE 'Auth user for Dr. RAMYA already exists: %', v_ramya_id;
  END IF;

  -- Upsert doctor row (idempotent)
  INSERT INTO public.doctors (
    first_name, last_name, email, phone,
    specialisation, is_active, consulting_fee,
    location, auth_user_id, username,
    created_at, updated_at
  ) VALUES (
    'RAMYA', NULL, v_auth_email, '+918008896416',
    'General Dentist', true, 0,
    'HYDERABAD', v_ramya_id, 'drramya',
    now(), now()
  )
  ON CONFLICT (email) DO UPDATE SET
    auth_user_id = EXCLUDED.auth_user_id,
    phone        = EXCLUDED.phone,
    updated_at   = now();

END $$;

-- ─────────────────────────────────────────────────────────────
-- Verify both doctors exist
-- ─────────────────────────────────────────────────────────────
SELECT id, first_name, last_name, email, phone, auth_user_id, created_at
FROM public.doctors
WHERE email IN ('suryadoc88@gmail.com', 'prathigadaparamya@gmail.com')
ORDER BY first_name;

