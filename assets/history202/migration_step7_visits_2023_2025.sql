-- =============================================================================
-- migration_step7_visits_2023_2025.sql
-- =============================================================================
-- Inserts visits and treatment_plans for 2023-2025 data.
--
-- Visits count         : 105
-- Treatment rows count : 374
-- Run order            : Step 7 (after Step 6)
-- Safe to re-run       : YES (WHERE NOT EXISTS guards)
-- =============================================================================

DO $$
DECLARE
  v_doctor_id  UUID;
  v_patient_id UUID;
  v_visit_id   UUID;
BEGIN
  -- Resolve doctor once
  SELECT id INTO v_doctor_id
  FROM doctors
  WHERE first_name ILIKE '%Surya%'
  LIMIT 1;

  IF v_doctor_id IS NULL THEN
    RAISE EXCEPTION 'Doctor with name Surya not found in doctors table';
  END IF;

  -- Visit: PRODONT312 on 2023-02-07
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT312' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-07', 'PRODONT312';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-07'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT316 on 2023-02-07
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT316' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-07', 'PRODONT316';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-07'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT318 on 2023-02-15
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT318' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-15', 'PRODONT318';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-15'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT322 on 2023-02-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT322' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-12', 'PRODONT322';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT323 on 2023-02-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT323' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-12', 'PRODONT323';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT324 on 2023-02-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT324' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-12', 'PRODONT324';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT325 on 2023-02-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT325' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-12', 'PRODONT325';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT326 on 2023-02-15
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT326' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-15', 'PRODONT326';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-15'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Implant Crown Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implant Crown Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implant Crown Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: ABUTMENT- OSSTEM
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'ABUTMENT- OSSTEM'
        AND COALESCE(description, '') = COALESCE('TSPTB451RWH', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'ABUTMENT- OSSTEM',
        'TSPTB451RWH',
        3200,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT333 on 2023-02-22
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT333' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-22', 'PRODONT333';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-22'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: CROWN CEMENTATION-RESIN MODIFIED GIC
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'CROWN CEMENTATION-RESIN MODIFIED GIC'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'CROWN CEMENTATION-RESIN MODIFIED GIC',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT337 on 2023-04-05
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT337' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-05', 'PRODONT337';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-05'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT338 on 2023-02-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT338' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-28', 'PRODONT338';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Focal Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Focal Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Focal Scaling',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Focal Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Focal Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Focal Scaling',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT338 on 2024-08-17
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT338' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-08-17', 'PRODONT338';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-08-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-08-17'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        8500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        8500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT339 on 2023-02-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT339' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-02-28', 'PRODONT339';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-02-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT342 on 2023-03-04
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT342' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-03-04', 'PRODONT342';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-03-04'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT346 on 2023-03-14
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT346' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-03-14', 'PRODONT346';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-14'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-03-14'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: LONG TERM TEMPERORY CROWNS
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'LONG TERM TEMPERORY CROWNS'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'LONG TERM TEMPERORY CROWNS',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT347 on 2023-03-19
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT347' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-03-19', 'PRODONT347';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-19'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-03-19'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT349 on 2023-03-25
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT349' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-03-25', 'PRODONT349';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-03-25'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT350 on 2023-03-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT350' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-03-28', 'PRODONT350';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-03-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Tooth Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Tooth Extraction'
        AND COALESCE(description, '') = COALESCE('Check if patient is on any blood thinners', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Tooth Extraction',
        'Check if patient is on any blood thinners',
        1200,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Tooth Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Tooth Extraction'
        AND COALESCE(description, '') = COALESCE('Check if patient is on any blood thinners', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Tooth Extraction',
        'Check if patient is on any blood thinners',
        1200,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT356 on 2023-04-03
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT356' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-03', 'PRODONT356';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-03'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        1200,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT357 on 2023-04-06
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT357' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-06', 'PRODONT357';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-06'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-06'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implants
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implants'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implants',
        NULL,
        25000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implant Crown Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implant Crown Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implant Crown Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Guide -Implant ( Guided surgery)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Guide -Implant ( Guided surgery)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Guide -Implant ( Guided surgery)',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT358 on 2023-04-07
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT358' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-07', 'PRODONT358';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-07'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT360 on 2023-04-22
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-22', 'PRODONT360';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-22'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restorations
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restorations'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restorations',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restorations
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restorations'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restorations',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT360 on 2024-09-10
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-09-10', 'PRODONT360';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-09-10'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT360 on 2024-09-17
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-09-17', 'PRODONT360';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-09-17'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT361 on 2023-04-23
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT361' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-23', 'PRODONT361';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-23'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-23'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Subgingival Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Subgingival Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Subgingival Scaling',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT362 on 2023-04-23
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT362' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-23', 'PRODONT362';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-23'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-23'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT362 on 2023-10-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT362' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-10-12', 'PRODONT362';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-10-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT365 on 2023-04-25
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT365' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-25', 'PRODONT365';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-25'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT365 on 2023-12-15
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT365' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-12-15', 'PRODONT365';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-12-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-12-15'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT366 on 2023-04-27
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT366' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-27', 'PRODONT366';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-27'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-27'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: CLEAR ALIGNERS - MULTILAYERED
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'CLEAR ALIGNERS - MULTILAYERED'
        AND COALESCE(description, '') = COALESCE('Scan - Planning - Assessment - IPR', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'CLEAR ALIGNERS - MULTILAYERED',
        'Scan - Planning - Assessment - IPR',
        150000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: IPR & ATTATCHMENT
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'IPR & ATTATCHMENT'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'IPR & ATTATCHMENT',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Clear Retainers UPPER & LOWER
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Clear Retainers UPPER & LOWER'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Clear Retainers UPPER & LOWER',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT368 on 2023-04-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT368' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-28', 'PRODONT368';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Pulp Therapy
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pulp Therapy'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pulp Therapy',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Pediatric Stainless Steel Crown For Deciduous Teeth
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pediatric Stainless Steel Crown For Deciduous Teeth'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pediatric Stainless Steel Crown For Deciduous Teeth',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT369 on 2023-04-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT369' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-04-28', 'PRODONT369';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-04-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT372 on 2023-05-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT372' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-05-12', 'PRODONT372';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-05-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-05-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT372 on 2023-05-20
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT372' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-05-20', 'PRODONT372';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-05-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-05-20'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        15000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT375 on 2023-06-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT375' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-06-16', 'PRODONT375';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-06-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-06-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Suture removal
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Suture removal'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Suture removal',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT376 on 2023-06-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT376' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-06-16', 'PRODONT376';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-06-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-06-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        7500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        7500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        4200,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        6500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        6500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT376 on 2025-01-20
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT376' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-01-20', 'PRODONT376';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-01-20'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT378 on 2023-07-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT378' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-01', 'PRODONT378';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Fixed Orthodontic Appliance
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Fixed Orthodontic Appliance'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Fixed Orthodontic Appliance',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT380 on 2023-07-02
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT380' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-02', 'PRODONT380';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-02'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT382 on 2023-07-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT382' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-01', 'PRODONT382';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT383 on 2023-07-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT383' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-01', 'PRODONT383';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT386 on 2023-07-11
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT386' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-11', 'PRODONT386';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-11'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-11'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Pulp Therapy
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pulp Therapy'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pulp Therapy',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Pediatric Stainless Steel Crowns for Deciduous teeth (3M)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pediatric Stainless Steel Crowns for Deciduous teeth (3M)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pediatric Stainless Steel Crowns for Deciduous teeth (3M)',
        NULL,
        3000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT389 on 2023-07-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT389' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-16', 'PRODONT389';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT391 on 2023-07-31
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT391' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-07-31', 'PRODONT391';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-31'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-07-31'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implants
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implants'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implants',
        NULL,
        25000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implant Crown Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implant Crown Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implant Crown Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Guide -Implant ( Guided surgery)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Guide -Implant ( Guided surgery)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Guide -Implant ( Guided surgery)',
        NULL,
        7000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implants
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implants'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implants',
        NULL,
        25000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implant Crown Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implant Crown Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implant Crown Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Guide -Implant ( Guided surgery)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Guide -Implant ( Guided surgery)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Guide -Implant ( Guided surgery)',
        NULL,
        7000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT392 on 2023-08-03
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT392' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-03', 'PRODONT392';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-03'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: CROWN CEMENTATION-RESIN MODIFIED GIC
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'CROWN CEMENTATION-RESIN MODIFIED GIC'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'CROWN CEMENTATION-RESIN MODIFIED GIC',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: CROWN CEMENTATION-RESIN MODIFIED GIC
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'CROWN CEMENTATION-RESIN MODIFIED GIC'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'CROWN CEMENTATION-RESIN MODIFIED GIC',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT394 on 2023-08-04
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT394' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-04', 'PRODONT394';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-04'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Ortho treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Ortho treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Ortho treatment',
        NULL,
        50000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT395 on 2023-08-04
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-04', 'PRODONT395';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-04'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        200,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        200,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT395 on 2024-10-26
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-10-26', 'PRODONT395';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-26'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-10-26'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT395 on 2025-03-09
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-03-09', 'PRODONT395';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-09'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-03-09'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Packable / Bulk Fill Composite Restoration (3M)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Packable / Bulk Fill Composite Restoration (3M)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Packable / Bulk Fill Composite Restoration (3M)',
        NULL,
        3000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Packable / Bulk Fill Composite Restoration (3M)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Packable / Bulk Fill Composite Restoration (3M)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Packable / Bulk Fill Composite Restoration (3M)',
        NULL,
        3000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Subgingival Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Subgingival Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Subgingival Scaling',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Subgingival Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Subgingival Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Subgingival Scaling',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT397 on 2023-08-10
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT397' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-10', 'PRODONT397';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-10'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT398 on 2023-08-21
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT398' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-21', 'PRODONT398';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-21'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT399 on 2023-08-21
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT399' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-08-21', 'PRODONT399';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-08-21'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT401 on 2023-09-09
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT401' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-09-09', 'PRODONT401';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-09'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-09-09'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Indirect Pulp Capping with Resin Modified GIC
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Indirect Pulp Capping with Resin Modified GIC'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Indirect Pulp Capping with Resin Modified GIC',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT402 on 2023-09-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT402' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-09-16', 'PRODONT402';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-09-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT403 on 2023-09-29
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT403' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-09-29', 'PRODONT403';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-09-29'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        8500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT404 on 2023-10-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT404' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-10-01', 'PRODONT404';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-10-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT405 on 2023-10-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT405' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-10-01', 'PRODONT405';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-10-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT408 on 2023-10-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT408' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-10-28', 'PRODONT408';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-10-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Composite Restoration- IVOCLAR
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Composite Restoration- IVOCLAR'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Composite Restoration- IVOCLAR',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT409 on 2023-11-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT409' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-11-01', 'PRODONT409';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-11-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-11-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Subgingival Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Subgingival Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Subgingival Scaling',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT410 on 2023-11-02
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT410' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-11-02', 'PRODONT410';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-11-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-11-02'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Fixed Orthodontic Appliance
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Fixed Orthodontic Appliance'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Fixed Orthodontic Appliance',
        NULL,
        90000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT411 on 2023-11-02
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT411' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2023-11-02', 'PRODONT411';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-11-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2023-11-02'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT418 on 2024-01-27
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-01-27', 'PRODONT418';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-01-27'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-01-27'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        14000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        14000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT418 on 2025-01-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-01-28', 'PRODONT418';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-01-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT418 on 2025-06-17
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-06-17', 'PRODONT418';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-06-17'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Replacememt of crown under warranty ( BASE CHARGES )
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Replacememt of crown under warranty ( BASE CHARGES )'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Replacememt of crown under warranty ( BASE CHARGES )',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Replacememt of crown under warranty ( BASE CHARGES )
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Replacememt of crown under warranty ( BASE CHARGES )'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Replacememt of crown under warranty ( BASE CHARGES )',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT423 on 2024-01-18
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT423' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-01-18', 'PRODONT423';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-01-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-01-18'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT423 on 2024-02-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT423' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-01', 'PRODONT423';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT424 on 2024-01-25
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT424' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-01-25', 'PRODONT424';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-01-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-01-25'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Subgingival Scaling
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Subgingival Scaling'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Subgingival Scaling',
        NULL,
        1500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT429 on 2024-02-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT429' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-01', 'PRODONT429';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Pulp Therapy
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pulp Therapy'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pulp Therapy',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: SS CROWN as a part of Pulp therapy
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'SS CROWN as a part of Pulp therapy'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'SS CROWN as a part of Pulp therapy',
        NULL,
        3000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT435 on 2024-02-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT435' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-12', 'PRODONT435';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: SUPRA & SUB GINGIVAL SCALING
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'SUPRA & SUB GINGIVAL SCALING'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'SUPRA & SUB GINGIVAL SCALING',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT436 on 2024-02-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT436' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-28', 'PRODONT436';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal'
        AND COALESCE(description, '') = COALESCE('Tell patients for follow-up visit after 1 week', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal',
        'Tell patients for follow-up visit after 1 week',
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Tooth Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Tooth Extraction'
        AND COALESCE(description, '') = COALESCE('Check if patient is on any blood thinners', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Tooth Extraction',
        'Check if patient is on any blood thinners',
        1000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: DMLS CROWN
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'DMLS CROWN'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'DMLS CROWN',
        NULL,
        6500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT448 on 2024-02-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT448' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-28', 'PRODONT448';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        3000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT448 on 2025-02-13
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT448' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-02-13', 'PRODONT448';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-02-13'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-02-13'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        200,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT449 on 2024-02-29
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT449' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-02-29', 'PRODONT449';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-02-29'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT458 on 2024-03-18
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT458' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-03-18', 'PRODONT458';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-03-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-03-18'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: SUPRA & SUB GINGIVAL SCALING
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'SUPRA & SUB GINGIVAL SCALING'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'SUPRA & SUB GINGIVAL SCALING',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT459 on 2024-03-21
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT459' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-03-21', 'PRODONT459';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-03-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-03-21'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT472 on 2024-05-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT472' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-05-01', 'PRODONT472';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-05-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-05-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT480 on 2024-05-21
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT480' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-05-21', 'PRODONT480';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-05-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-05-21'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Impression Making
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Impression Making'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Impression Making',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING DAMON CLE
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING DAMON CLEAR (CERAMIC ) BRACES'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING DAMON CLEAR (CERAMIC ) BRACES',
        NULL,
        100000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Orthodontic retainers- Post treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Orthodontic retainers- Post treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Orthodontic retainers- Post treatment',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT483 on 2024-06-13
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-06-13', 'PRODONT483';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-06-13'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-06-13'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT483 on 2024-06-18
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-06-18', 'PRODONT483';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-06-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-06-18'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: DMLS CROWN
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'DMLS CROWN'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'DMLS CROWN',
        NULL,
        6500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT483 on 2024-07-18
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-07-18', 'PRODONT483';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-07-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-07-18'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal'
        AND COALESCE(description, '') = COALESCE('Tell patients for follow-up visit after 1 week', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal',
        'Tell patients for follow-up visit after 1 week',
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: DMLS CROWN
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'DMLS CROWN'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'DMLS CROWN',
        NULL,
        6500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT484 on 2024-07-02
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT484' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-07-02', 'PRODONT484';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-07-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-07-02'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT485 on 2024-07-05
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT485' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-07-05', 'PRODONT485';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-07-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-07-05'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: SUPRA & SUB GINGIVAL SCALING
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'SUPRA & SUB GINGIVAL SCALING'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'SUPRA & SUB GINGIVAL SCALING',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT491 on 2024-09-17
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT491' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-09-17', 'PRODONT491';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-09-17'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT492 on 2024-09-25
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-09-25', 'PRODONT492';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-09-25'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT492 on 2024-10-03
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-10-03', 'PRODONT492';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-10-03'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Re-RCT
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Re-RCT'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Re-RCT',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT492 on 2025-05-02
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-05-02', 'PRODONT492';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-05-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-05-02'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Implants
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Implants'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Implants',
        NULL,
        37000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        400,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT494 on 2024-10-15
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT494' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-10-15', 'PRODONT494';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-10-15'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT495 on 2024-10-17
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT495' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-10-17', 'PRODONT495';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-10-17'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Free Gingival Grafting for Root Coverage - Full thickness
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Free Gingival Grafting for Root Coverage - Full thickness'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Free Gingival Grafting for Root Coverage - Full thickness',
        NULL,
        25000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT496 on 2024-12-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT496' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-12-01', 'PRODONT496';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-12-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: DMLS CROWN
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'DMLS CROWN'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'DMLS CROWN',
        NULL,
        7000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT497 on 2024-12-08
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT497' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-12-08', 'PRODONT497';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-08'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-12-08'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Pediatric Stainless Steel Crown For Deciduous Teeth
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Pediatric Stainless Steel Crown For Deciduous Teeth'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Pediatric Stainless Steel Crown For Deciduous Teeth',
        NULL,
        4000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        1500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: PULPECTOMY & STAINLESS STEEL CROWN placememt
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'PULPECTOMY & STAINLESS STEEL CROWN placememt'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'PULPECTOMY & STAINLESS STEEL CROWN placememt',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT498 on 2024-12-22
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT498' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2024-12-22', 'PRODONT498';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2024-12-22'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Onlay - Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Onlay - Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Onlay - Zirconia',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT502 on 2025-01-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT502' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-01-16', 'PRODONT502';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-01-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        4500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Re-RCT
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Re-RCT'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Re-RCT',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Tooth Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Tooth Extraction'
        AND COALESCE(description, '') = COALESCE('Check if patient is on any blood thinners', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Tooth Extraction',
        'Check if patient is on any blood thinners',
        4000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT504 on 2025-01-16
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT504' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-01-16', 'PRODONT504';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-01-16'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT505 on 2025-01-28
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT505' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-01-28', 'PRODONT505';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-01-28'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT506 on 2025-02-01
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT506' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-02-01', 'PRODONT506';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-02-01'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        800,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Oral Prophylaxis with Polishing
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Oral Prophylaxis with Polishing'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Oral Prophylaxis with Polishing',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT508 on 2025-03-11
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT508' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-03-11', 'PRODONT508';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-11'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-03-11'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT510 on 2025-03-29
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT510' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-03-29', 'PRODONT510';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-03-29'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: SUPRA & SUB GINGIVAL SCALING
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'SUPRA & SUB GINGIVAL SCALING'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'SUPRA & SUB GINGIVAL SCALING',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT512 on 2025-04-10
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT512' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-04-10', 'PRODONT512';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-04-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-04-10'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        500,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Packable / Bulk Fill Composite Restoration (3M)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Packable / Bulk Fill Composite Restoration (3M)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Packable / Bulk Fill Composite Restoration (3M)',
        NULL,
        2000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT514 on 2025-04-10
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT514' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-04-10', 'PRODONT514';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-04-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-04-10'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT515 on 2025-05-05
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT515' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-05-05', 'PRODONT515';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-05-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-05-05'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Surgical Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Surgical Extraction'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Surgical Extraction',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        400,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Suture removal
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Suture removal'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Suture removal',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT516 on 2025-06-08
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT516' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-06-08', 'PRODONT516';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-08'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-06-08'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Curretage
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Curretage'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Curretage',
        NULL,
        1000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: X RAY (RADIOGRAPH-RVG)
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'X RAY (RADIOGRAPH-RVG)'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'X RAY (RADIOGRAPH-RVG)',
        NULL,
        300,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crown removal
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crown removal'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crown removal',
        NULL,
        1500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT517 on 2025-06-12
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT517' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-06-12', 'PRODONT517';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-06-12'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Tooth Extraction
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Tooth Extraction'
        AND COALESCE(description, '') = COALESCE('Check if patient is on any blood thinners', '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Tooth Extraction',
        'Check if patient is on any blood thinners',
        2000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: DMLS CROWN
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'DMLS CROWN'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'DMLS CROWN',
        NULL,
        8000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT518 on 2025-06-20
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT518' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-06-20', 'PRODONT518';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-06-20'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Follow-Up
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Follow-Up'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Follow-Up',
        NULL,
        0,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        6000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        10000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        2500,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT520 on 2025-06-30
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT520' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-06-30', 'PRODONT520';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-30'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-06-30'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Root Canal Treatment
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Root Canal Treatment'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Root Canal Treatment',
        NULL,
        5000,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Crowns-Zirconia
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Crowns-Zirconia'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Crowns-Zirconia',
        NULL,
        9000,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

  -- Visit: PRODONT521 on 2025-07-21
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT521' LIMIT 1;
  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping visit on 2025-07-21', 'PRODONT521';
  ELSE
    -- Insert visit if not exists
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-07-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      v_visit_id := gen_random_uuid();
      INSERT INTO public.visits (
        id, patient_id, doctor_id,
        visit_date, status,
        created_at, updated_at
      ) VALUES (
        v_visit_id,
        v_patient_id,
        v_doctor_id,
        '2025-07-21'::timestamptz,
        'complete',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        4,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Consultation
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Consultation'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Consultation',
        NULL,
        600,
        'planned',
        now(), now()
      );
    END IF;

    -- Treatment: Resin Modified GIC Restoration
    IF NOT EXISTS (
      SELECT 1 FROM public.treatment_plans
      WHERE visit_id = v_visit_id
        AND treatment_name = 'Resin Modified GIC Restoration'
        AND COALESCE(description, '') = COALESCE(NULL, '')
    ) THEN
      INSERT INTO public.treatment_plans (
        id, visit_id,
        treatment_name, description,
        total_cost,
        status,
        created_at, updated_at
      ) VALUES (
        gen_random_uuid(),
        v_visit_id,
        'Resin Modified GIC Restoration',
        NULL,
        4,
        'planned',
        now(), now()
      );
    END IF;

  END IF;

END $$;

-- Verification
SELECT
  (SELECT COUNT(*) FROM public.visits
   WHERE created_at >= NOW() - INTERVAL '1 day') AS visits_inserted_today,
  (SELECT COUNT(*) FROM public.treatment_plans
   WHERE created_at >= NOW() - INTERVAL '1 day') AS treatments_inserted_today;
