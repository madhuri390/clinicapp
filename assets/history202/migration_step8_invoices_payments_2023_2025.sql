-- =============================================================================
-- migration_step8_invoices_payments_2023_2025.sql
-- =============================================================================
-- Inserts invoices and payments for 2023-2025 data.
--
-- Invoices count        : 99  (INV101 skipped - Ramya G unmatchable)
-- Total payment rows    : 301
-- Run order             : Step 8 (after Steps 6 and 7)
-- Safe to re-run        : YES (WHERE NOT EXISTS guards)
-- =============================================================================

DO $$
DECLARE
  v_patient_id UUID;
  v_visit_id   UUID;
  v_invoice_id UUID;
BEGIN

  -- Invoice: INV102 | Patient: PRODONT316 | Date: 2023-02-07 | Total: 15500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT316' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV102', 'PRODONT316';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-07, skipping invoice INV102', 'PRODONT316';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15500,
        15500,
        0,
        '2023-02-07'::date,
        now(),
        'INV102'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV102'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV102' LIMIT 1;

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INV102 - Root Canal Treatment',
        '2023-02-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV102 - Root Canal Treatment'
          AND payment_date::date = '2023-02-07'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INV102 - Crowns-Zirconia',
        '2023-02-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV102 - Crowns-Zirconia'
          AND payment_date::date = '2023-02-07'::date
      );

      -- Payment: UPI 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INV102 - Composite Restoration- IVOCLAR',
        '2023-02-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV102 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-02-07'::date
      );

    END IF;
  END IF;

  -- Invoice: INV103 | Patient: PRODONT317 | Date: 2023-02-09 | Total: 3600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT317' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV103', 'PRODONT317';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INV103', 'PRODONT317';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        3600,
        3600,
        0,
        '2023-02-09'::date,
        now(),
        'INV103'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV103'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV103' LIMIT 1;

      -- Payment: UPI 1800 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1800,
        'UPI'::payment_mode_type,
        'Migrated INV103 - Oral Prophylaxis with Polishing',
        '2023-02-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV103 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2023-02-09'::date
      );

    END IF;
  END IF;

  -- Invoice: INV104 | Patient: PRODONT312 | Date: 2023-02-09 | Total: 6000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT312' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV104', 'PRODONT312';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-07, skipping invoice INV104', 'PRODONT312';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        6000,
        6000,
        0,
        '2023-02-09'::date,
        now(),
        'INV104'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV104'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV104' LIMIT 1;

      -- Payment: UPI 6000 for Root Canal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'UPI'::payment_mode_type,
        'Migrated INV104 - Root Canal',
        '2023-02-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV104 - Root Canal'
          AND payment_date::date = '2023-02-09'::date
      );

    END IF;
  END IF;

  -- Invoice: INV105 | Patient: PRODONT322 | Date: 2023-02-12 | Total: 19500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT322' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV105', 'PRODONT322';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-12, skipping invoice INV105', 'PRODONT322';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        19500,
        19500,
        0,
        '2023-02-12'::date,
        now(),
        'INV105'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV105'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV105' LIMIT 1;

      -- Payment: Cash 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'Cash'::payment_mode_type,
        'Migrated INV105 - Root Canal Treatment',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV105 - Root Canal Treatment'
          AND payment_date::date = '2023-02-12'::date
      );

      -- Payment: Cash 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INV105 - Crowns-Zirconia',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV105 - Crowns-Zirconia'
          AND payment_date::date = '2023-02-12'::date
      );

      -- Payment: Cash 6000 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INV105 - Surgical Extraction',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV105 - Surgical Extraction'
          AND payment_date::date = '2023-02-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INV107 | Patient: PRODONT323 | Date: 2023-02-12 | Total: 27000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT323' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV107', 'PRODONT323';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-12, skipping invoice INV107', 'PRODONT323';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        27000,
        27000,
        0,
        '2023-02-12'::date,
        now(),
        'INV107'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV107'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV107' LIMIT 1;

      -- Payment: Cash 9000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INV107 - Root Canal Treatment',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV107 - Root Canal Treatment'
          AND payment_date::date = '2023-02-12'::date
      );

      -- Payment: Cash 18000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        18000,
        'Cash'::payment_mode_type,
        'Migrated INV107 - Crowns-Zirconia',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV107 - Crowns-Zirconia'
          AND payment_date::date = '2023-02-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INV109 | Patient: PRODONT325 | Date: 2023-02-12 | Total: 27000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT325' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INV109', 'PRODONT325';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-12, skipping invoice INV109', 'PRODONT325';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        27000,
        27000,
        0,
        '2023-02-12'::date,
        now(),
        'INV109'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INV109'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INV109' LIMIT 1;

      -- Payment: Cash 9000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INV109 - Root Canal Treatment',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV109 - Root Canal Treatment'
          AND payment_date::date = '2023-02-12'::date
      );

      -- Payment: Cash 18000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        18000,
        'Cash'::payment_mode_type,
        'Migrated INV109 - Crowns-Zirconia',
        '2023-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INV109 - Crowns-Zirconia'
          AND payment_date::date = '2023-02-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT111 | Patient: PRODONT326 | Date: 2023-02-15 | Total: 13200
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT326' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT111', 'PRODONT326';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-15, skipping invoice INVPRODONT111', 'PRODONT326';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        13200,
        13200,
        0,
        '2023-02-15'::date,
        now(),
        'INVPRODONT111'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT111'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT111' LIMIT 1;

      -- Payment: UPI 10000 for Implant Crown Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT111 - Implant Crown Zirconia',
        '2023-02-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT111 - Implant Crown Zirconia'
          AND payment_date::date = '2023-02-15'::date
      );

      -- Payment: UPI 3200 for ABUTMENT- OSSTEM
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT111 - ABUTMENT- OSSTEM',
        '2023-02-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT111 - ABUTMENT- OSSTEM'
          AND payment_date::date = '2023-02-15'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT112 | Patient: PRODONT333 | Date: 2023-02-22 | Total: 1400
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT333' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT112', 'PRODONT333';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-22, skipping invoice INVPRODONT112', 'PRODONT333';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1400,
        1400,
        0,
        '2023-02-22'::date,
        now(),
        'INVPRODONT112'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT112'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT112' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT112 - Consultation',
        '2023-02-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT112 - Consultation'
          AND payment_date::date = '2023-02-22'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT112 - X RAY (RADIOGRAPH-RVG)',
        '2023-02-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT112 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-02-22'::date
      );

      -- Payment: UPI 800 for CROWN CEMENTATION-RESIN MODIFIED GIC
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        800,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT112 - CROWN CEMENTATION-RESIN MODIFIED GIC',
        '2023-02-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT112 - CROWN CEMENTATION-RESIN MODIFIED GIC'
          AND payment_date::date = '2023-02-22'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT113 | Patient: PRODONT338 | Date: 2023-02-28 | Total: 1600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT338' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT113', 'PRODONT338';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-28, skipping invoice INVPRODONT113', 'PRODONT338';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1600,
        1600,
        0,
        '2023-02-28'::date,
        now(),
        'INVPRODONT113'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT113'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT113' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT113 - Consultation',
        '2023-02-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT113 - Consultation'
          AND payment_date::date = '2023-02-28'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT113 - X RAY (RADIOGRAPH-RVG)',
        '2023-02-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT113 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-02-28'::date
      );

      -- Payment: UPI 1000 for Focal Scaling
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT113 - Focal Scaling',
        '2023-02-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT113 - Focal Scaling'
          AND payment_date::date = '2023-02-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT114 | Patient: PRODONT339 | Date: 2023-02-28 | Total: 1100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT339' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT114', 'PRODONT339';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-02-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-02-28, skipping invoice INVPRODONT114', 'PRODONT339';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1100,
        1100,
        0,
        '2023-02-28'::date,
        now(),
        'INVPRODONT114'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT114'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT114' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT114 - Consultation',
        '2023-02-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT114 - Consultation'
          AND payment_date::date = '2023-02-28'::date
      );

      -- Payment: UPI 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT114 - X RAY (RADIOGRAPH-RVG)',
        '2023-02-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT114 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-02-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT115 | Patient: PRODONT342 | Date: 2023-03-04 | Total: 600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT342' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT115', 'PRODONT342';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-03-04, skipping invoice INVPRODONT115', 'PRODONT342';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        600,
        600,
        0,
        '2023-03-04'::date,
        now(),
        'INVPRODONT115'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT115'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT115' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT115 - Consultation',
        '2023-03-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT115 - Consultation'
          AND payment_date::date = '2023-03-04'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT115 - X RAY (RADIOGRAPH-RVG)',
        '2023-03-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT115 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-03-04'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT116 | Patient: PRODONT336 | Date: 2023-03-11 | Total: 15000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT336' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT116', 'PRODONT336';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INVPRODONT116', 'PRODONT336';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15000,
        15000,
        0,
        '2023-03-11'::date,
        now(),
        'INVPRODONT116'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT116'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT116' LIMIT 1;

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT116 - Root Canal Treatment',
        '2023-03-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT116 - Root Canal Treatment'
          AND payment_date::date = '2023-03-11'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT116 - Crowns-Zirconia',
        '2023-03-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT116 - Crowns-Zirconia'
          AND payment_date::date = '2023-03-11'::date
      );

      -- Payment: UPI 1500 for Indirect Composite Resin Restorations
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT116 - Indirect Composite Resin Restorations',
        '2023-03-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT116 - Indirect Composite Resin Restorations'
          AND payment_date::date = '2023-03-11'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT117 | Patient: PRODONT346 | Date: 2023-03-14 | Total: 18200
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT346' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT117', 'PRODONT346';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-14'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-03-14, skipping invoice INVPRODONT117', 'PRODONT346';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        18200,
        18200,
        0,
        '2023-03-14'::date,
        now(),
        'INVPRODONT117'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT117'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT117' LIMIT 1;

      -- Payment: Card 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT117 - Consultation',
        '2023-03-14'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT117 - Consultation'
          AND payment_date::date = '2023-03-14'::date
      );

      -- Payment: Card 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT117 - Root Canal Treatment',
        '2023-03-14'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT117 - Root Canal Treatment'
          AND payment_date::date = '2023-03-14'::date
      );

      -- Payment: Card 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT117 - X RAY (RADIOGRAPH-RVG)',
        '2023-03-14'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT117 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-03-14'::date
      );

      -- Payment: Card 4000 for LONG TERM TEMPERORY CROWNS
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT117 - LONG TERM TEMPERORY CROWNS',
        '2023-03-14'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT117 - LONG TERM TEMPERORY CROWNS'
          AND payment_date::date = '2023-03-14'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT118 | Patient: PRODONT347 | Date: 2023-03-19 | Total: 500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT347' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT118', 'PRODONT347';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-19'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-03-19, skipping invoice INVPRODONT118', 'PRODONT347';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        500,
        500,
        0,
        '2023-03-19'::date,
        now(),
        'INVPRODONT118'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT118'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT118' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT118 - Consultation',
        '2023-03-19'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT118 - Consultation'
          AND payment_date::date = '2023-03-19'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT119 | Patient: PRODONT349 | Date: 2023-03-25 | Total: 14100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT349' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT119', 'PRODONT349';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-03-25, skipping invoice INVPRODONT119', 'PRODONT349';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        14100,
        14100,
        0,
        '2023-03-25'::date,
        now(),
        'INVPRODONT119'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT119'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT119' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT119 - Consultation',
        '2023-03-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT119 - Consultation'
          AND payment_date::date = '2023-03-25'::date
      );

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT119 - Root Canal Treatment',
        '2023-03-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT119 - Root Canal Treatment'
          AND payment_date::date = '2023-03-25'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT119 - Crowns-Zirconia',
        '2023-03-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT119 - Crowns-Zirconia'
          AND payment_date::date = '2023-03-25'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT119 - X RAY (RADIOGRAPH-RVG)',
        '2023-03-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT119 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-03-25'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT120 | Patient: PRODONT350 | Date: 2023-03-28 | Total: 1800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT350' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT120', 'PRODONT350';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-03-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-03-28, skipping invoice INVPRODONT120', 'PRODONT350';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1800,
        1800,
        0,
        '2023-03-28'::date,
        now(),
        'INVPRODONT120'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT120'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT120' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT120 - Consultation',
        '2023-03-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT120 - Consultation'
          AND payment_date::date = '2023-03-28'::date
      );

      -- Payment: UPI 1200 for Tooth Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT120 - Tooth Extraction',
        '2023-03-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT120 - Tooth Extraction'
          AND payment_date::date = '2023-03-28'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT120 - X RAY (RADIOGRAPH-RVG)',
        '2023-03-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT120 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-03-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT121 | Patient: PRODONT356 | Date: 2023-04-03 | Total: 6600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT356' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT121', 'PRODONT356';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-03, skipping invoice INVPRODONT121', 'PRODONT356';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        6600,
        6600,
        0,
        '2023-04-03'::date,
        now(),
        'INVPRODONT121'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT121'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT121' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT121 - Consultation',
        '2023-04-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT121 - Consultation'
          AND payment_date::date = '2023-04-03'::date
      );

      -- Payment: UPI 6000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT121 - Composite Restoration- IVOCLAR',
        '2023-04-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT121 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-04-03'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT121 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT121 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-03'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT122 | Patient: PRODONT337 | Date: 2023-04-05 | Total: 16100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT337' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT122', 'PRODONT337';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-05, skipping invoice INVPRODONT122', 'PRODONT337';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        16100,
        16100,
        0,
        '2023-04-05'::date,
        now(),
        'INVPRODONT122'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT122'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT122' LIMIT 1;

      -- Payment: Card 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT122 - Consultation',
        '2023-04-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT122 - Consultation'
          AND payment_date::date = '2023-04-05'::date
      );

      -- Payment: Card 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT122 - Root Canal Treatment',
        '2023-04-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT122 - Root Canal Treatment'
          AND payment_date::date = '2023-04-05'::date
      );

      -- Payment: Card 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT122 - Crowns-Zirconia',
        '2023-04-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT122 - Crowns-Zirconia'
          AND payment_date::date = '2023-04-05'::date
      );

      -- Payment: Card 2000 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT122 - Oral Prophylaxis with Polishing',
        '2023-04-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT122 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2023-04-05'::date
      );

      -- Payment: Card 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT122 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT122 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-05'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT123 | Patient: PRODONT357 | Date: 2023-04-06 | Total: 41600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT357' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT123', 'PRODONT357';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-06'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-06, skipping invoice INVPRODONT123', 'PRODONT357';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        41600,
        41600,
        0,
        '2023-04-06'::date,
        now(),
        'INVPRODONT123'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT123'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT123' LIMIT 1;

      -- Payment: Card 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT123 - Consultation',
        '2023-04-06'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT123 - Consultation'
          AND payment_date::date = '2023-04-06'::date
      );

      -- Payment: Card 25000 for Implants
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        25000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT123 - Implants',
        '2023-04-06'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT123 - Implants'
          AND payment_date::date = '2023-04-06'::date
      );

      -- Payment: Card 10000 for Implant Crown Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT123 - Implant Crown Zirconia',
        '2023-04-06'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT123 - Implant Crown Zirconia'
          AND payment_date::date = '2023-04-06'::date
      );

      -- Payment: Card 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT123 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-06'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT123 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-06'::date
      );

      -- Payment: Card 6000 for Surgical Guide -Implant ( Guided surgery)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT123 - Surgical Guide -Implant ( Guided surgery)',
        '2023-04-06'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT123 - Surgical Guide -Implant ( Guided surgery)'
          AND payment_date::date = '2023-04-06'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT124 | Patient: PRODONT358 | Date: 2023-04-07 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT358' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT124', 'PRODONT358';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-07'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-07, skipping invoice INVPRODONT124', 'PRODONT358';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2023-04-07'::date,
        now(),
        'INVPRODONT124'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT124'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT124' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT124 - Consultation',
        '2023-04-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT124 - Consultation'
          AND payment_date::date = '2023-04-07'::date
      );

      -- Payment: UPI 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT124 - Composite Restoration- IVOCLAR',
        '2023-04-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT124 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-04-07'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT124 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-07'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT124 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-07'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT125 | Patient: PRODONT360 | Date: 2023-04-22 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT125', 'PRODONT360';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-22, skipping invoice INVPRODONT125', 'PRODONT360';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2023-04-22'::date,
        now(),
        'INVPRODONT125'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT125'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT125' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT125 - Consultation',
        '2023-04-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT125 - Consultation'
          AND payment_date::date = '2023-04-22'::date
      );

      -- Payment: UPI 500 for Composite Restorations
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT125 - Composite Restorations',
        '2023-04-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT125 - Composite Restorations'
          AND payment_date::date = '2023-04-22'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT126 | Patient: PRODONT362 | Date: 2023-04-23 | Total: 4600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT362' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT126', 'PRODONT362';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-23'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-23, skipping invoice INVPRODONT126', 'PRODONT362';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        4600,
        4600,
        0,
        '2023-04-23'::date,
        now(),
        'INVPRODONT126'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT126'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT126' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT126 - Consultation',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT126 - Consultation'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT126 - Composite Restoration- IVOCLAR',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT126 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 2000 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT126 - Oral Prophylaxis with Polishing',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT126 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT126 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT126 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-23'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT127 | Patient: PRODONT361 | Date: 2023-04-23 | Total: 5300
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT361' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT127', 'PRODONT361';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-23'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-23, skipping invoice INVPRODONT127', 'PRODONT361';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        5300,
        5300,
        0,
        '2023-04-23'::date,
        now(),
        'INVPRODONT127'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT127'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT127' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT127 - Consultation',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT127 - Consultation'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT127 - Composite Restoration- IVOCLAR',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT127 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT127 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT127 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-23'::date
      );

      -- Payment: UPI 2500 for Subgingival Scaling
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT127 - Subgingival Scaling',
        '2023-04-23'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT127 - Subgingival Scaling'
          AND payment_date::date = '2023-04-23'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT128 | Patient: PRODONT365 | Date: 2023-04-25 | Total: 600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT365' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT128', 'PRODONT365';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-25, skipping invoice INVPRODONT128', 'PRODONT365';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        600,
        600,
        0,
        '2023-04-25'::date,
        now(),
        'INVPRODONT128'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT128'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT128' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT128 - Consultation',
        '2023-04-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT128 - Consultation'
          AND payment_date::date = '2023-04-25'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT128 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT128 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-25'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT129 | Patient: PRODONT366 | Date: 2023-04-27 | Total: 168000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT366' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT129', 'PRODONT366';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-27'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-27, skipping invoice INVPRODONT129', 'PRODONT366';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        168000,
        168000,
        0,
        '2023-04-27'::date,
        now(),
        'INVPRODONT129'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT129'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT129' LIMIT 1;

      -- Payment: UPI 150000 for CLEAR ALIGNERS - MULTILAYERED
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        150000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT129 - CLEAR ALIGNERS - MULTILAYERED',
        '2023-04-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT129 - CLEAR ALIGNERS - MULTILAYERED'
          AND payment_date::date = '2023-04-27'::date
      );

      -- Payment: UPI 10000 for IPR & ATTATCHMENT
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT129 - IPR & ATTATCHMENT',
        '2023-04-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT129 - IPR & ATTATCHMENT'
          AND payment_date::date = '2023-04-27'::date
      );

      -- Payment: UPI 8000 for Clear Retainers UPPER & LOWER
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT129 - Clear Retainers UPPER & LOWER',
        '2023-04-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT129 - Clear Retainers UPPER & LOWER'
          AND payment_date::date = '2023-04-27'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT130 | Patient: PRODONT368 | Date: 2023-04-28 | Total: 8600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT368' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT130', 'PRODONT368';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-28, skipping invoice INVPRODONT130', 'PRODONT368';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        8600,
        8600,
        0,
        '2023-04-28'::date,
        now(),
        'INVPRODONT130'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT130'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT130' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT130 - Consultation',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT130 - Consultation'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: UPI 8000 for Pulp Therapy
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT130 - Pulp Therapy',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT130 - Pulp Therapy'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: UPI 0 for Pediatric Stainless Steel Crown For Deciduous Teet
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT130 - Pediatric Stainless Steel Crown For Deciduous Teeth',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT130 - Pediatric Stainless Steel Crown For Deciduous Teeth'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT130 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT130 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT131 | Patient: PRODONT367 | Date: 2023-04-28 | Total: 16900
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT367' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT131', 'PRODONT367';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INVPRODONT131', 'PRODONT367';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        16900,
        16900,
        0,
        '2023-04-28'::date,
        now(),
        'INVPRODONT131'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT131'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT131' LIMIT 1;

      -- Payment: Card 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT131 - Consultation',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT131 - Consultation'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: Card 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT131 - Root Canal Treatment',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT131 - Root Canal Treatment'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: Card 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT131 - Crowns-Zirconia',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT131 - Crowns-Zirconia'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: Card 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT131 - Composite Restoration- IVOCLAR',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT131 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-04-28'::date
      );

      -- Payment: Card 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT131 - X RAY (RADIOGRAPH-RVG)',
        '2023-04-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT131 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-04-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT132 | Patient: PRODONT372 | Date: 2023-05-12 | Total: 5100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT372' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT132', 'PRODONT372';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-05-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-05-12, skipping invoice INVPRODONT132', 'PRODONT372';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        5100,
        5100,
        0,
        '2023-05-12'::date,
        now(),
        'INVPRODONT132'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT132'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT132' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT132 - Consultation',
        '2023-05-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT132 - Consultation'
          AND payment_date::date = '2023-05-12'::date
      );

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT132 - Root Canal Treatment',
        '2023-05-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT132 - Root Canal Treatment'
          AND payment_date::date = '2023-05-12'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT132 - X RAY (RADIOGRAPH-RVG)',
        '2023-05-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT132 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-05-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT133 | Patient: PRODONT372 | Date: 2023-05-20 | Total: 20100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT372' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT133', 'PRODONT372';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-05-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-05-20, skipping invoice INVPRODONT133', 'PRODONT372';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        20100,
        20100,
        0,
        '2023-05-20'::date,
        now(),
        'INVPRODONT133'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT133'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT133' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT133 - Consultation',
        '2023-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT133 - Consultation'
          AND payment_date::date = '2023-05-20'::date
      );

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT133 - Root Canal Treatment',
        '2023-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT133 - Root Canal Treatment'
          AND payment_date::date = '2023-05-20'::date
      );

      -- Payment: UPI 15000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        15000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT133 - Crowns-Zirconia',
        '2023-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT133 - Crowns-Zirconia'
          AND payment_date::date = '2023-05-20'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT133 - X RAY (RADIOGRAPH-RVG)',
        '2023-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT133 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-05-20'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT134 | Patient: PRODONT375 | Date: 2023-06-16 | Total: 10100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT375' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT134', 'PRODONT375';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-06-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-06-16, skipping invoice INVPRODONT134', 'PRODONT375';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        10100,
        10100,
        0,
        '2023-06-16'::date,
        now(),
        'INVPRODONT134'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT134'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT134' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT134 - Consultation',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT134 - Consultation'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 8000 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT134 - Surgical Extraction',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT134 - Surgical Extraction'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 1200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT134 - X RAY (RADIOGRAPH-RVG)',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT134 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 600 for Suture removal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT134 - Suture removal',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT134 - Suture removal'
          AND payment_date::date = '2023-06-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT135 | Patient: PRODONT376 | Date: 2023-06-16 | Total: 35000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT376' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT135', 'PRODONT376';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-06-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-06-16, skipping invoice INVPRODONT135', 'PRODONT376';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        35000,
        35000,
        0,
        '2023-06-16'::date,
        now(),
        'INVPRODONT135'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT135'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT135' LIMIT 1;

      -- Payment: UPI 800 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        800,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT135 - Consultation',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT135 - Consultation'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 15000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        15000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT135 - Root Canal Treatment',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT135 - Root Canal Treatment'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 4200 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT135 - Crowns-Zirconia',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT135 - Crowns-Zirconia'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 13000 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        13000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT135 - Surgical Extraction',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT135 - Surgical Extraction'
          AND payment_date::date = '2023-06-16'::date
      );

      -- Payment: UPI 2000 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT135 - X RAY (RADIOGRAPH-RVG)',
        '2023-06-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT135 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-06-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT138 | Patient: PRODONT365 | Date: 2023-07-01 | Total: 5900
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT365' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT138', 'PRODONT365';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-04-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-04-25, skipping invoice INVPRODONT138', 'PRODONT365';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        5900,
        5900,
        0,
        '2023-07-01'::date,
        now(),
        'INVPRODONT138'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT138'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT138' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT138 - Consultation',
        '2023-07-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT138 - Consultation'
          AND payment_date::date = '2023-07-01'::date
      );

      -- Payment: UPI 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT138 - Root Canal Treatment',
        '2023-07-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT138 - Root Canal Treatment'
          AND payment_date::date = '2023-07-01'::date
      );

      -- Payment: UPI 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT138 - X RAY (RADIOGRAPH-RVG)',
        '2023-07-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT138 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-07-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT139 | Patient: PRODONT380 | Date: 2023-07-02 | Total: 2300
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT380' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT139', 'PRODONT380';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-07-02, skipping invoice INVPRODONT139', 'PRODONT380';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2300,
        2300,
        0,
        '2023-07-02'::date,
        now(),
        'INVPRODONT139'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT139'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT139' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT139 - Consultation',
        '2023-07-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT139 - Consultation'
          AND payment_date::date = '2023-07-02'::date
      );

      -- Payment: UPI 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT139 - Composite Restoration- IVOCLAR',
        '2023-07-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT139 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-07-02'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT140 | Patient: PRODONT386 | Date: 2023-07-11 | Total: 11600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT386' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT140', 'PRODONT386';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-11'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-07-11, skipping invoice INVPRODONT140', 'PRODONT386';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        11600,
        11600,
        0,
        '2023-07-11'::date,
        now(),
        'INVPRODONT140'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT140'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT140' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT140 - Consultation',
        '2023-07-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT140 - Consultation'
          AND payment_date::date = '2023-07-11'::date
      );

      -- Payment: UPI 8000 for Pulp Therapy
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT140 - Pulp Therapy',
        '2023-07-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT140 - Pulp Therapy'
          AND payment_date::date = '2023-07-11'::date
      );

      -- Payment: UPI 3000 for Pediatric Stainless Steel Crowns for Deciduous tee
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT140 - Pediatric Stainless Steel Crowns for Deciduous teeth (3M)',
        '2023-07-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT140 - Pediatric Stainless Steel Crowns for Deciduous teeth (3M)'
          AND payment_date::date = '2023-07-11'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT140 - X RAY (RADIOGRAPH-RVG)',
        '2023-07-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT140 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-07-11'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT141 | Patient: PRODONT389 | Date: 2023-07-16 | Total: 12000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT389' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT141', 'PRODONT389';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-07-16, skipping invoice INVPRODONT141', 'PRODONT389';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        12000,
        12000,
        0,
        '2023-07-16'::date,
        now(),
        'INVPRODONT141'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT141'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT141' LIMIT 1;

      -- Payment: Cash 0 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT141 - Consultation',
        '2023-07-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT141 - Consultation'
          AND payment_date::date = '2023-07-16'::date
      );

      -- Payment: Cash 4000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT141 - Root Canal Treatment',
        '2023-07-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT141 - Root Canal Treatment'
          AND payment_date::date = '2023-07-16'::date
      );

      -- Payment: Cash 8000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT141 - Crowns-Zirconia',
        '2023-07-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT141 - Crowns-Zirconia'
          AND payment_date::date = '2023-07-16'::date
      );

      -- Payment: Cash 0 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT141 - X RAY (RADIOGRAPH-RVG)',
        '2023-07-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT141 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-07-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT142 | Patient: PRODONT391 | Date: 2023-07-31 | Total: 42600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT391' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT142', 'PRODONT391';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-07-31'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-07-31, skipping invoice INVPRODONT142', 'PRODONT391';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        42600,
        42600,
        0,
        '2023-07-31'::date,
        now(),
        'INVPRODONT142'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT142'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT142' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT142 - Consultation',
        '2023-07-31'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT142 - Consultation'
          AND payment_date::date = '2023-07-31'::date
      );

      -- Payment: Cash 25000 for Implants
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        25000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT142 - Implants',
        '2023-07-31'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT142 - Implants'
          AND payment_date::date = '2023-07-31'::date
      );

      -- Payment: Cash 10000 for Implant Crown Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT142 - Implant Crown Zirconia',
        '2023-07-31'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT142 - Implant Crown Zirconia'
          AND payment_date::date = '2023-07-31'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT142 - X RAY (RADIOGRAPH-RVG)',
        '2023-07-31'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT142 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-07-31'::date
      );

      -- Payment: Cash 7000 for Surgical Guide -Implant ( Guided surgery)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        7000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT142 - Surgical Guide -Implant ( Guided surgery)',
        '2023-07-31'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT142 - Surgical Guide -Implant ( Guided surgery)'
          AND payment_date::date = '2023-07-31'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT144 | Patient: PRODONT392 | Date: 2023-08-03 | Total: 1600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT392' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT144', 'PRODONT392';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-03, skipping invoice INVPRODONT144', 'PRODONT392';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1600,
        1600,
        0,
        '2023-08-03'::date,
        now(),
        'INVPRODONT144'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT144'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT144' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT144 - Consultation',
        '2023-08-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT144 - Consultation'
          AND payment_date::date = '2023-08-03'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT144 - X RAY (RADIOGRAPH-RVG)',
        '2023-08-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT144 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-08-03'::date
      );

      -- Payment: UPI 1000 for CROWN CEMENTATION-RESIN MODIFIED GIC
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT144 - CROWN CEMENTATION-RESIN MODIFIED GIC',
        '2023-08-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT144 - CROWN CEMENTATION-RESIN MODIFIED GIC'
          AND payment_date::date = '2023-08-03'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT145 | Patient: PRODONT394 | Date: 2023-08-04 | Total: 50000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT394' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT145', 'PRODONT394';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-04, skipping invoice INVPRODONT145', 'PRODONT394';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        50000,
        50000,
        0,
        '2023-08-04'::date,
        now(),
        'INVPRODONT145'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT145'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT145' LIMIT 1;

      -- Payment: Card 50000 for Ortho treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        50000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT145 - Ortho treatment',
        '2023-08-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT145 - Ortho treatment'
          AND payment_date::date = '2023-08-04'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT146 | Patient: PRODONT395 | Date: 2023-08-04 | Total: 14500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT146', 'PRODONT395';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-04'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-04, skipping invoice INVPRODONT146', 'PRODONT395';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        14500,
        14500,
        0,
        '2023-08-04'::date,
        now(),
        'INVPRODONT146'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT146'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT146' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT146 - Consultation',
        '2023-08-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT146 - Consultation'
          AND payment_date::date = '2023-08-04'::date
      );

      -- Payment: UPI 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT146 - Root Canal Treatment',
        '2023-08-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT146 - Root Canal Treatment'
          AND payment_date::date = '2023-08-04'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT146 - Crowns-Zirconia',
        '2023-08-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT146 - Crowns-Zirconia'
          AND payment_date::date = '2023-08-04'::date
      );

      -- Payment: UPI 200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT146 - X RAY (RADIOGRAPH-RVG)',
        '2023-08-04'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT146 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-08-04'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT147 | Patient: PRODONT397 | Date: 2023-08-10 | Total: 13800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT397' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT147', 'PRODONT397';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-10, skipping invoice INVPRODONT147', 'PRODONT397';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        13800,
        13800,
        0,
        '2023-08-10'::date,
        now(),
        'INVPRODONT147'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT147'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT147' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT147 - Consultation',
        '2023-08-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT147 - Consultation'
          AND payment_date::date = '2023-08-10'::date
      );

      -- Payment: UPI 4500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT147 - Root Canal Treatment',
        '2023-08-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT147 - Root Canal Treatment'
          AND payment_date::date = '2023-08-10'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT147 - Crowns-Zirconia',
        '2023-08-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT147 - Crowns-Zirconia'
          AND payment_date::date = '2023-08-10'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT148 | Patient: PRODONT398 | Date: 2023-08-21 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT398' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT148', 'PRODONT398';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-21, skipping invoice INVPRODONT148', 'PRODONT398';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2023-08-21'::date,
        now(),
        'INVPRODONT148'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT148'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT148' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT148 - Consultation',
        '2023-08-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT148 - Consultation'
          AND payment_date::date = '2023-08-21'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT148 - X RAY (RADIOGRAPH-RVG)',
        '2023-08-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT148 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-08-21'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT149 | Patient: PRODONT399 | Date: 2023-08-21 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT399' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT149', 'PRODONT399';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-08-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-08-21, skipping invoice INVPRODONT149', 'PRODONT399';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2023-08-21'::date,
        now(),
        'INVPRODONT149'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT149'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT149' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT149 - Consultation',
        '2023-08-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT149 - Consultation'
          AND payment_date::date = '2023-08-21'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT149 - X RAY (RADIOGRAPH-RVG)',
        '2023-08-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT149 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-08-21'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT150 | Patient: PRODONT401 | Date: 2023-09-09 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT401' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT150', 'PRODONT401';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-09'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-09-09, skipping invoice INVPRODONT150', 'PRODONT401';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2023-09-09'::date,
        now(),
        'INVPRODONT150'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT150'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT150' LIMIT 1;

      -- Payment: UPI 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT150 - Consultation',
        '2023-09-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT150 - Consultation'
          AND payment_date::date = '2023-09-09'::date
      );

      -- Payment: UPI 2000 for Indirect Pulp Capping with Resin Modified GIC
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT150 - Indirect Pulp Capping with Resin Modified GIC',
        '2023-09-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT150 - Indirect Pulp Capping with Resin Modified GIC'
          AND payment_date::date = '2023-09-09'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT150 - X RAY (RADIOGRAPH-RVG)',
        '2023-09-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT150 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-09-09'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT151 | Patient: PRODONT402 | Date: 2023-09-16 | Total: 15700
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT402' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT151', 'PRODONT402';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-09-16, skipping invoice INVPRODONT151', 'PRODONT402';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15700,
        15700,
        0,
        '2023-09-16'::date,
        now(),
        'INVPRODONT151'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT151'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT151' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT151 - Consultation',
        '2023-09-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT151 - Consultation'
          AND payment_date::date = '2023-09-16'::date
      );

      -- Payment: UPI 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT151 - Root Canal Treatment',
        '2023-09-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT151 - Root Canal Treatment'
          AND payment_date::date = '2023-09-16'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT151 - Crowns-Zirconia',
        '2023-09-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT151 - Crowns-Zirconia'
          AND payment_date::date = '2023-09-16'::date
      );

      -- Payment: UPI 1200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT151 - X RAY (RADIOGRAPH-RVG)',
        '2023-09-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT151 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-09-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT152 | Patient: PRODONT403 | Date: 2023-09-29 | Total: 11100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT403' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT152', 'PRODONT403';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-09-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-09-29, skipping invoice INVPRODONT152', 'PRODONT403';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        11100,
        11100,
        0,
        '2023-09-29'::date,
        now(),
        'INVPRODONT152'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT152'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT152' LIMIT 1;

      -- Payment: UPI 600 for Suture removal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT152 - Suture removal',
        '2023-09-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT152 - Suture removal'
          AND payment_date::date = '2023-09-29'::date
      );

      -- Payment: UPI 800 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        800,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT152 - Consultation',
        '2023-09-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT152 - Consultation'
          AND payment_date::date = '2023-09-29'::date
      );

      -- Payment: UPI 8500 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT152 - Surgical Extraction',
        '2023-09-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT152 - Surgical Extraction'
          AND payment_date::date = '2023-09-29'::date
      );

      -- Payment: UPI 1200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT152 - X RAY (RADIOGRAPH-RVG)',
        '2023-09-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT152 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-09-29'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT153 | Patient: PRODONT404 | Date: 2023-10-01 | Total: 900
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT404' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT153', 'PRODONT404';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-10-01, skipping invoice INVPRODONT153', 'PRODONT404';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        900,
        900,
        0,
        '2023-10-01'::date,
        now(),
        'INVPRODONT153'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT153'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT153' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT153 - Consultation',
        '2023-10-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT153 - Consultation'
          AND payment_date::date = '2023-10-01'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT153 - X RAY (RADIOGRAPH-RVG)',
        '2023-10-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT153 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-10-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT154 | Patient: PRODONT405 | Date: 2023-10-01 | Total: 600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT405' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT154', 'PRODONT405';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-10-01, skipping invoice INVPRODONT154', 'PRODONT405';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        600,
        600,
        0,
        '2023-10-01'::date,
        now(),
        'INVPRODONT154'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT154'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT154' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT154 - Consultation',
        '2023-10-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT154 - Consultation'
          AND payment_date::date = '2023-10-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT155 | Patient: PRODONT362 | Date: 2023-10-12 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT362' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT155', 'PRODONT362';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-10-12, skipping invoice INVPRODONT155', 'PRODONT362';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2023-10-12'::date,
        now(),
        'INVPRODONT155'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT155'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT155' LIMIT 1;

      -- Payment: Card 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT155 - Consultation',
        '2023-10-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT155 - Consultation'
          AND payment_date::date = '2023-10-12'::date
      );

      -- Payment: Card 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT155 - Composite Restoration- IVOCLAR',
        '2023-10-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT155 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-10-12'::date
      );

      -- Payment: Card 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT155 - X RAY (RADIOGRAPH-RVG)',
        '2023-10-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT155 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-10-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT156 | Patient: PRODONT408 | Date: 2023-10-28 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT408' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT156', 'PRODONT408';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-10-28, skipping invoice INVPRODONT156', 'PRODONT408';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2023-10-28'::date,
        now(),
        'INVPRODONT156'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT156'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT156' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT156 - Consultation',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT156 - Consultation'
          AND payment_date::date = '2023-10-28'::date
      );

      -- Payment: Cash 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT156 - Composite Restoration- IVOCLAR',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT156 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-10-28'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT156 - X RAY (RADIOGRAPH-RVG)',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT156 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-10-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT157 | Patient: PRODONT408 | Date: 2023-10-28 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT408' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT157', 'PRODONT408';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-10-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-10-28, skipping invoice INVPRODONT157', 'PRODONT408';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2023-10-28'::date,
        now(),
        'INVPRODONT157'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT157'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT157' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT157 - Consultation',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT157 - Consultation'
          AND payment_date::date = '2023-10-28'::date
      );

      -- Payment: Cash 2000 for Composite Restoration- IVOCLAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT157 - Composite Restoration- IVOCLAR',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT157 - Composite Restoration- IVOCLAR'
          AND payment_date::date = '2023-10-28'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT157 - X RAY (RADIOGRAPH-RVG)',
        '2023-10-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT157 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-10-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT158 | Patient: PRODONT409 | Date: 2023-11-01 | Total: 2800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT409' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT158', 'PRODONT409';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-11-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-11-01, skipping invoice INVPRODONT158', 'PRODONT409';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2800,
        2800,
        0,
        '2023-11-01'::date,
        now(),
        'INVPRODONT158'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT158'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT158' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT158 - Consultation',
        '2023-11-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT158 - Consultation'
          AND payment_date::date = '2023-11-01'::date
      );

      -- Payment: Cash 2500 for Subgingival Scaling
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT158 - Subgingival Scaling',
        '2023-11-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT158 - Subgingival Scaling'
          AND payment_date::date = '2023-11-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT159 | Patient: PRODONT410 | Date: 2023-11-02 | Total: 181000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT410' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT159', 'PRODONT410';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-11-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-11-02, skipping invoice INVPRODONT159', 'PRODONT410';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        181000,
        181000,
        0,
        '2023-11-02'::date,
        now(),
        'INVPRODONT159'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT159'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT159' LIMIT 1;

      -- Payment: Card 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT159 - Consultation',
        '2023-11-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT159 - Consultation'
          AND payment_date::date = '2023-11-02'::date
      );

      -- Payment: Card 90000 for Fixed Orthodontic Appliance
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        90000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT159 - Fixed Orthodontic Appliance',
        '2023-11-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT159 - Fixed Orthodontic Appliance'
          AND payment_date::date = '2023-11-02'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT161 | Patient: PRODONT365 | Date: 2023-12-15 | Total: 18400
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT365' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT161', 'PRODONT365';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2023-12-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2023-12-15, skipping invoice INVPRODONT161', 'PRODONT365';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        18400,
        18400,
        0,
        '2023-12-15'::date,
        now(),
        'INVPRODONT161'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT161'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT161' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT161 - Consultation',
        '2023-12-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT161 - Consultation'
          AND payment_date::date = '2023-12-15'::date
      );

      -- Payment: UPI 6000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT161 - Root Canal Treatment',
        '2023-12-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT161 - Root Canal Treatment'
          AND payment_date::date = '2023-12-15'::date
      );

      -- Payment: UPI 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT161 - Crowns-Zirconia',
        '2023-12-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT161 - Crowns-Zirconia'
          AND payment_date::date = '2023-12-15'::date
      );

      -- Payment: UPI 2000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT161 - Resin Modified GIC Restoration',
        '2023-12-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT161 - Resin Modified GIC Restoration'
          AND payment_date::date = '2023-12-15'::date
      );

      -- Payment: UPI 900 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        900,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT161 - X RAY (RADIOGRAPH-RVG)',
        '2023-12-15'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT161 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2023-12-15'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT162 | Patient: PRODONT423 | Date: 2024-01-18 | Total: 1200
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT423' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT162', 'PRODONT423';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-01-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-01-18, skipping invoice INVPRODONT162', 'PRODONT423';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        1200,
        1200,
        0,
        '2024-01-18'::date,
        now(),
        'INVPRODONT162'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT162'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT162' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT162 - Consultation',
        '2024-01-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT162 - Consultation'
          AND payment_date::date = '2024-01-18'::date
      );

      -- Payment: Cash 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT162 - X RAY (RADIOGRAPH-RVG)',
        '2024-01-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT162 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-01-18'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT164 | Patient: PRODONT418 | Date: 2024-01-27 | Total: 40500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT164', 'PRODONT418';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-01-27'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-01-27, skipping invoice INVPRODONT164', 'PRODONT418';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        40500,
        40500,
        0,
        '2024-01-27'::date,
        now(),
        'INVPRODONT164'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT164'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT164' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT164 - Consultation',
        '2024-01-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT164 - Consultation'
          AND payment_date::date = '2024-01-27'::date
      );

      -- Payment: Cash 10000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT164 - Root Canal Treatment',
        '2024-01-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT164 - Root Canal Treatment'
          AND payment_date::date = '2024-01-27'::date
      );

      -- Payment: Cash 28000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        28000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT164 - Crowns-Zirconia',
        '2024-01-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT164 - Crowns-Zirconia'
          AND payment_date::date = '2024-01-27'::date
      );

      -- Payment: Cash 2000 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT164 - Oral Prophylaxis with Polishing',
        '2024-01-27'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT164 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2024-01-27'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT165 | Patient: PRODONT423 | Date: 2024-02-01 | Total: 2500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT423' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT165', 'PRODONT423';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-02-01, skipping invoice INVPRODONT165', 'PRODONT423';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2500,
        2500,
        0,
        '2024-02-01'::date,
        now(),
        'INVPRODONT165'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT165'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT165' LIMIT 1;

      -- Payment: UPI 2500 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT165 - Oral Prophylaxis with Polishing',
        '2024-02-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT165 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2024-02-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT166 | Patient: PRODONT429 | Date: 2024-02-01 | Total: 9000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT429' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT166', 'PRODONT429';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-02-01, skipping invoice INVPRODONT166', 'PRODONT429';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        9000,
        9000,
        0,
        '2024-02-01'::date,
        now(),
        'INVPRODONT166'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT166'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT166' LIMIT 1;

      -- Payment: Card 6000 for Pulp Therapy
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT166 - Pulp Therapy',
        '2024-02-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT166 - Pulp Therapy'
          AND payment_date::date = '2024-02-01'::date
      );

      -- Payment: Card 3000 for SS CROWN as a part of Pulp therapy
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3000,
        'Card'::payment_mode_type,
        'Migrated INVPRODONT166 - SS CROWN as a part of Pulp therapy',
        '2024-02-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT166 - SS CROWN as a part of Pulp therapy'
          AND payment_date::date = '2024-02-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT168 | Patient: PRODONT435 | Date: 2024-02-12 | Total: 4000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT435' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT168', 'PRODONT435';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-02-12, skipping invoice INVPRODONT168', 'PRODONT435';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        4000,
        4000,
        0,
        '2024-02-12'::date,
        now(),
        'INVPRODONT168'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT168'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT168' LIMIT 1;

      -- Payment: Cash 4000 for SUPRA & SUB GINGIVAL SCALING
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT168 - SUPRA & SUB GINGIVAL SCALING',
        '2024-02-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT168 - SUPRA & SUB GINGIVAL SCALING'
          AND payment_date::date = '2024-02-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT170 | Patient: PRODONT447 | Date: 2024-02-02 | Total: 4100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT447' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT170', 'PRODONT447';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INVPRODONT170', 'PRODONT447';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        4100,
        4100,
        0,
        '2024-02-02'::date,
        now(),
        'INVPRODONT170'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT170'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT170' LIMIT 1;

      -- Payment: Cash 800 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        800,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT170 - Consultation',
        '2024-02-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT170 - Consultation'
          AND payment_date::date = '2024-02-02'::date
      );

      -- Payment: Cash 3000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT170 - Resin Modified GIC Restoration',
        '2024-02-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT170 - Resin Modified GIC Restoration'
          AND payment_date::date = '2024-02-02'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT170 - X RAY (RADIOGRAPH-RVG)',
        '2024-02-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT170 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-02-02'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT171 | Patient: PRODONT449 | Date: 2024-02-29 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT449' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT171', 'PRODONT449';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-02-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-02-29, skipping invoice INVPRODONT171', 'PRODONT449';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2024-02-29'::date,
        now(),
        'INVPRODONT171'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT171'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT171' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT171 - Consultation',
        '2024-02-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT171 - Consultation'
          AND payment_date::date = '2024-02-29'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT171 - X RAY (RADIOGRAPH-RVG)',
        '2024-02-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT171 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-02-29'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT172 | Patient: PRODONT458 | Date: 2024-03-18 | Total: 4100
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT458' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT172', 'PRODONT458';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-03-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-03-18, skipping invoice INVPRODONT172', 'PRODONT458';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        4100,
        4100,
        0,
        '2024-03-18'::date,
        now(),
        'INVPRODONT172'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT172'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT172' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT172 - Consultation',
        '2024-03-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT172 - Consultation'
          AND payment_date::date = '2024-03-18'::date
      );

      -- Payment: Cash 500 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT172 - Oral Prophylaxis with Polishing',
        '2024-03-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT172 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2024-03-18'::date
      );

      -- Payment: Cash 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT172 - X RAY (RADIOGRAPH-RVG)',
        '2024-03-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT172 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-03-18'::date
      );

      -- Payment: Cash 2500 for SUPRA & SUB GINGIVAL SCALING
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT172 - SUPRA & SUB GINGIVAL SCALING',
        '2024-03-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT172 - SUPRA & SUB GINGIVAL SCALING'
          AND payment_date::date = '2024-03-18'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT174 | Patient: PRODONT460 | Date: 2024-03-21 | Total: 200000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT460' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT174', 'PRODONT460';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INVPRODONT174', 'PRODONT460';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        200000,
        200000,
        0,
        '2024-03-21'::date,
        now(),
        'INVPRODONT174'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT174'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT174' LIMIT 1;

      -- Payment: Cash 100000 for Ortho treatment using DAMON CLEAR
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        100000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT174 - Ortho treatment using DAMON CLEAR',
        '2024-03-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT174 - Ortho treatment using DAMON CLEAR'
          AND payment_date::date = '2024-03-21'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT178 | Patient: PRODONT480 | Date: 2024-05-20 | Total: 110000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT480' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT178', 'PRODONT480';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-05-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-05-21, skipping invoice INVPRODONT178', 'PRODONT480';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        110000,
        110000,
        0,
        '2024-05-20'::date,
        now(),
        'INVPRODONT178'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT178'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT178' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT178 - Consultation',
        '2024-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT178 - Consultation'
          AND payment_date::date = '2024-05-20'::date
      );

      -- Payment: UPI 500 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT178 - Follow-Up',
        '2024-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT178 - Follow-Up'
          AND payment_date::date = '2024-05-20'::date
      );

      -- Payment: UPI 1000 for Impression Making
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT178 - Impression Making',
        '2024-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT178 - Impression Making'
          AND payment_date::date = '2024-05-20'::date
      );

      -- Payment: UPI 100000 for ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        100000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT178 - ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING DAMON CLEAR (CERAMIC ) BRACES',
        '2024-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT178 - ORTHODONTIC CORRECTION OF MAXILLA & MANDIBLE USING DAMON CLEAR (CERAMIC ) BRACES'
          AND payment_date::date = '2024-05-20'::date
      );

      -- Payment: UPI 8000 for Orthodontic retainers- Post treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT178 - Orthodontic retainers- Post treatment',
        '2024-05-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT178 - Orthodontic retainers- Post treatment'
          AND payment_date::date = '2024-05-20'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT179 | Patient: PRODONT483 | Date: 2024-06-13 | Total: 10200
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT179', 'PRODONT483';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-06-13'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-06-13, skipping invoice INVPRODONT179', 'PRODONT483';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        10200,
        10200,
        0,
        '2024-06-13'::date,
        now(),
        'INVPRODONT179'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT179'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT179' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT179 - Consultation',
        '2024-06-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT179 - Consultation'
          AND payment_date::date = '2024-06-13'::date
      );

      -- Payment: Cash 0 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT179 - Follow-Up',
        '2024-06-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT179 - Follow-Up'
          AND payment_date::date = '2024-06-13'::date
      );

      -- Payment: Cash 9000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT179 - Root Canal Treatment',
        '2024-06-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT179 - Root Canal Treatment'
          AND payment_date::date = '2024-06-13'::date
      );

      -- Payment: Cash 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT179 - X RAY (RADIOGRAPH-RVG)',
        '2024-06-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT179 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-06-13'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT180 | Patient: PRODONT483 | Date: 2024-06-18 | Total: 499500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT180', 'PRODONT483';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-06-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-06-18, skipping invoice INVPRODONT180', 'PRODONT483';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        499500,
        499500,
        0,
        '2024-06-18'::date,
        now(),
        'INVPRODONT180'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT180'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT180' LIMIT 1;

      -- Payment: Cash 49500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        49500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - Root Canal Treatment',
        '2024-06-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - Root Canal Treatment'
          AND payment_date::date = '2024-06-18'::date
      );

      -- Payment: Cash 117000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        117000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - DMLS CROWN',
        '2024-06-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - DMLS CROWN'
          AND payment_date::date = '2024-06-18'::date
      );

      -- Payment: Cash 49500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        49500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - Root Canal Treatment',
        '2024-06-19'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - Root Canal Treatment'
          AND payment_date::date = '2024-06-19'::date
      );

      -- Payment: Cash 117000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        117000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - DMLS CROWN',
        '2024-06-19'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - DMLS CROWN'
          AND payment_date::date = '2024-06-19'::date
      );

      -- Payment: Cash 49500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        49500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - Root Canal Treatment',
        '2024-06-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - Root Canal Treatment'
          AND payment_date::date = '2024-06-29'::date
      );

      -- Payment: Cash 117000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        117000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT180 - DMLS CROWN',
        '2024-06-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT180 - DMLS CROWN'
          AND payment_date::date = '2024-06-29'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT182 | Patient: PRODONT485 | Date: 2024-05-02 | Total: 4000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT485' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT182', 'PRODONT485';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-07-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-07-05, skipping invoice INVPRODONT182', 'PRODONT485';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        4000,
        4000,
        0,
        '2024-05-02'::date,
        now(),
        'INVPRODONT182'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT182'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT182' LIMIT 1;

      -- Payment: Cash 4000 for SUPRA & SUB GINGIVAL SCALING
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT182 - SUPRA & SUB GINGIVAL SCALING',
        '2024-05-02'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT182 - SUPRA & SUB GINGIVAL SCALING'
          AND payment_date::date = '2024-05-02'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT183 | Patient: PRODONT483 | Date: 2024-06-29 | Total: 166500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT483' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT183', 'PRODONT483';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-06-18'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-06-18, skipping invoice INVPRODONT183', 'PRODONT483';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        166500,
        166500,
        0,
        '2024-06-29'::date,
        now(),
        'INVPRODONT183'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT183'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT183' LIMIT 1;

      -- Payment: Cash 49500 for Root Canal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        49500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT183 - Root Canal',
        '2024-06-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT183 - Root Canal'
          AND payment_date::date = '2024-06-29'::date
      );

      -- Payment: Cash 117000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        117000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT183 - DMLS CROWN',
        '2024-06-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT183 - DMLS CROWN'
          AND payment_date::date = '2024-06-29'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT184 | Patient: PRODONT338 | Date: 2024-08-17 | Total: 9500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT338' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT184', 'PRODONT338';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-08-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-08-17, skipping invoice INVPRODONT184', 'PRODONT338';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        9500,
        9500,
        0,
        '2024-08-17'::date,
        now(),
        'INVPRODONT184'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT184'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT184' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT184 - Consultation',
        '2024-08-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT184 - Consultation'
          AND payment_date::date = '2024-08-17'::date
      );

      -- Payment: Cash 8500 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT184 - Surgical Extraction',
        '2024-08-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT184 - Surgical Extraction'
          AND payment_date::date = '2024-08-17'::date
      );

      -- Payment: Cash 500 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT184 - X RAY (RADIOGRAPH-RVG)',
        '2024-08-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT184 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-08-17'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT185 | Patient: PRODONT360 | Date: 2024-09-10 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT185', 'PRODONT360';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-09-10, skipping invoice INVPRODONT185', 'PRODONT360';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2024-09-10'::date,
        now(),
        'INVPRODONT185'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT185'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT185' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT185 - Consultation',
        '2024-09-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT185 - Consultation'
          AND payment_date::date = '2024-09-10'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT185 - X RAY (RADIOGRAPH-RVG)',
        '2024-09-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT185 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-09-10'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT186 | Patient: PRODONT360 | Date: 2024-09-17 | Total: 2500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT360' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT186', 'PRODONT360';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-09-17, skipping invoice INVPRODONT186', 'PRODONT360';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2500,
        2500,
        0,
        '2024-09-17'::date,
        now(),
        'INVPRODONT186'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT186'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT186' LIMIT 1;

      -- Payment: Cash 2500 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT186 - Resin Modified GIC Restoration',
        '2024-09-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT186 - Resin Modified GIC Restoration'
          AND payment_date::date = '2024-09-17'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT187 | Patient: PRODONT491 | Date: 2024-09-17 | Total: 5500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT491' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT187', 'PRODONT491';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-09-17, skipping invoice INVPRODONT187', 'PRODONT491';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        5500,
        5500,
        0,
        '2024-09-17'::date,
        now(),
        'INVPRODONT187'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT187'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT187' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT187 - Consultation',
        '2024-09-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT187 - Consultation'
          AND payment_date::date = '2024-09-17'::date
      );

      -- Payment: Cash 5000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT187 - Resin Modified GIC Restoration',
        '2024-09-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT187 - Resin Modified GIC Restoration'
          AND payment_date::date = '2024-09-17'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT188 | Patient: PRODONT492 | Date: 2024-09-25 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT188', 'PRODONT492';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-09-25'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-09-25, skipping invoice INVPRODONT188', 'PRODONT492';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2024-09-25'::date,
        now(),
        'INVPRODONT188'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT188'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT188' LIMIT 1;

      -- Payment: UPI 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT188 - Consultation',
        '2024-09-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT188 - Consultation'
          AND payment_date::date = '2024-09-25'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT188 - X RAY (RADIOGRAPH-RVG)',
        '2024-09-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT188 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-09-25'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT189 | Patient: PRODONT492 | Date: 2024-10-03 | Total: 48000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT189', 'PRODONT492';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-03'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-10-03, skipping invoice INVPRODONT189', 'PRODONT492';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        48000,
        48000,
        0,
        '2024-10-03'::date,
        now(),
        'INVPRODONT189'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT189'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT189' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT189 - Consultation',
        '2024-10-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT189 - Consultation'
          AND payment_date::date = '2024-10-03'::date
      );

      -- Payment: Cash 10000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT189 - Root Canal Treatment',
        '2024-10-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT189 - Root Canal Treatment'
          AND payment_date::date = '2024-10-03'::date
      );

      -- Payment: Cash 6000 for Re-RCT
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT189 - Re-RCT',
        '2024-10-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT189 - Re-RCT'
          AND payment_date::date = '2024-10-03'::date
      );

      -- Payment: Cash 30000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        30000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT189 - Crowns-Zirconia',
        '2024-10-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT189 - Crowns-Zirconia'
          AND payment_date::date = '2024-10-03'::date
      );

      -- Payment: Cash 1500 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT189 - X RAY (RADIOGRAPH-RVG)',
        '2024-10-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT189 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-10-03'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT190 | Patient: PRODONT494 | Date: 2024-10-05 | Total: 15200
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT494' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT190', 'PRODONT494';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-15'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-10-15, skipping invoice INVPRODONT190', 'PRODONT494';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15200,
        15200,
        0,
        '2024-10-05'::date,
        now(),
        'INVPRODONT190'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT190'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT190' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT190 - Consultation',
        '2024-10-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT190 - Consultation'
          AND payment_date::date = '2024-10-05'::date
      );

      -- Payment: Cash 500 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT190 - Follow-Up',
        '2024-10-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT190 - Follow-Up'
          AND payment_date::date = '2024-10-05'::date
      );

      -- Payment: Cash 4000 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT190 - Surgical Extraction',
        '2024-10-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT190 - Surgical Extraction'
          AND payment_date::date = '2024-10-05'::date
      );

      -- Payment: Cash 1200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT190 - X RAY (RADIOGRAPH-RVG)',
        '2024-10-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT190 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-10-05'::date
      );

      -- Payment: Cash 9000 for PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT190 - PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION',
        '2024-10-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT190 - PRIMARY CLOSURE OF ORO ANTRAL COMMUNICATION'
          AND payment_date::date = '2024-10-05'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT191 | Patient: PRODONT495 | Date: 2024-10-17 | Total: 25000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT495' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT191', 'PRODONT495';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-10-17, skipping invoice INVPRODONT191', 'PRODONT495';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        25000,
        25000,
        0,
        '2024-10-17'::date,
        now(),
        'INVPRODONT191'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT191'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT191' LIMIT 1;

      -- Payment: Cash 25000 for Free Gingival Grafting for Root Coverage - Full th
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        25000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT191 - Free Gingival Grafting for Root Coverage - Full thickness',
        '2024-10-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT191 - Free Gingival Grafting for Root Coverage - Full thickness'
          AND payment_date::date = '2024-10-17'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT192 | Patient: PRODONT395 | Date: 2024-10-26 | Total: 800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT192', 'PRODONT395';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-10-26'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-10-26, skipping invoice INVPRODONT192', 'PRODONT395';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        800,
        800,
        0,
        '2024-10-26'::date,
        now(),
        'INVPRODONT192'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT192'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT192' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT192 - Consultation',
        '2024-10-26'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT192 - Consultation'
          AND payment_date::date = '2024-10-26'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT192 - X RAY (RADIOGRAPH-RVG)',
        '2024-10-26'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT192 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2024-10-26'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT193 | Patient: PRODONT496 | Date: 2024-12-01 | Total: 13500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT496' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT193', 'PRODONT496';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-12-01, skipping invoice INVPRODONT193', 'PRODONT496';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        13500,
        13500,
        0,
        '2024-12-01'::date,
        now(),
        'INVPRODONT193'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT193'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT193' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT193 - Consultation',
        '2024-12-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT193 - Consultation'
          AND payment_date::date = '2024-12-01'::date
      );

      -- Payment: Cash 6000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT193 - Root Canal Treatment',
        '2024-12-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT193 - Root Canal Treatment'
          AND payment_date::date = '2024-12-01'::date
      );

      -- Payment: Cash 7000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        7000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT193 - DMLS CROWN',
        '2024-12-01'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT193 - DMLS CROWN'
          AND payment_date::date = '2024-12-01'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT194 | Patient: PRODONT497 | Date: 2024-12-08 | Total: 15500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT497' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT194', 'PRODONT497';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-08'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-12-08, skipping invoice INVPRODONT194', 'PRODONT497';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15500,
        15500,
        0,
        '2024-12-08'::date,
        now(),
        'INVPRODONT194'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT194'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT194' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT194 - Consultation',
        '2024-12-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT194 - Consultation'
          AND payment_date::date = '2024-12-08'::date
      );

      -- Payment: Cash 4000 for Pediatric Stainless Steel Crown For Deciduous Teet
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT194 - Pediatric Stainless Steel Crown For Deciduous Teeth',
        '2024-12-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT194 - Pediatric Stainless Steel Crown For Deciduous Teeth'
          AND payment_date::date = '2024-12-08'::date
      );

      -- Payment: Cash 3000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT194 - Resin Modified GIC Restoration',
        '2024-12-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT194 - Resin Modified GIC Restoration'
          AND payment_date::date = '2024-12-08'::date
      );

      -- Payment: Cash 8000 for PULPECTOMY & STAINLESS STEEL CROWN placememt
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT194 - PULPECTOMY & STAINLESS STEEL CROWN placememt',
        '2024-12-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT194 - PULPECTOMY & STAINLESS STEEL CROWN placememt'
          AND payment_date::date = '2024-12-08'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT195 | Patient: PRODONT498 | Date: 2024-12-22 | Total: 8500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT498' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT195', 'PRODONT498';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2024-12-22'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2024-12-22, skipping invoice INVPRODONT195', 'PRODONT498';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        8500,
        8500,
        0,
        '2024-12-22'::date,
        now(),
        'INVPRODONT195'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT195'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT195' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT195 - Consultation',
        '2024-12-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT195 - Consultation'
          AND payment_date::date = '2024-12-22'::date
      );

      -- Payment: Cash 8000 for Onlay - Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT195 - Onlay - Zirconia',
        '2024-12-22'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT195 - Onlay - Zirconia'
          AND payment_date::date = '2024-12-22'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT196 | Patient: PRODONT502 | Date: 2025-01-16 | Total: 162800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT502' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT196', 'PRODONT502';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-01-16, skipping invoice INVPRODONT196', 'PRODONT502';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        162800,
        162800,
        0,
        '2025-01-16'::date,
        now(),
        'INVPRODONT196'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT196'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT196' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT196 - Consultation',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT196 - Consultation'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 31500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        31500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT196 - Root Canal Treatment',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT196 - Root Canal Treatment'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 6000 for Re-RCT
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT196 - Re-RCT',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT196 - Re-RCT'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 117000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        117000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT196 - Crowns-Zirconia',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT196 - Crowns-Zirconia'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 8000 for Tooth Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT196 - Tooth Extraction',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT196 - Tooth Extraction'
          AND payment_date::date = '2025-01-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT197 | Patient: PRODONT504 | Date: 2025-01-16 | Total: 15500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT504' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT197', 'PRODONT504';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-16'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-01-16, skipping invoice INVPRODONT197', 'PRODONT504';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15500,
        15500,
        0,
        '2025-01-16'::date,
        now(),
        'INVPRODONT197'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT197'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT197' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT197 - Consultation',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT197 - Consultation'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT197 - Root Canal Treatment',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT197 - Root Canal Treatment'
          AND payment_date::date = '2025-01-16'::date
      );

      -- Payment: Cash 10000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT197 - Crowns-Zirconia',
        '2025-01-16'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT197 - Crowns-Zirconia'
          AND payment_date::date = '2025-01-16'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT198 | Patient: PRODONT376 | Date: 2025-01-20 | Total: 47000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT376' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT198', 'PRODONT376';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-01-20, skipping invoice INVPRODONT198', 'PRODONT376';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        47000,
        47000,
        0,
        '2025-01-20'::date,
        now(),
        'INVPRODONT198'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT198'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT198' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT198 - Consultation',
        '2025-01-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT198 - Consultation'
          AND payment_date::date = '2025-01-20'::date
      );

      -- Payment: Cash 16500 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        16500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT198 - Root Canal Treatment',
        '2025-01-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT198 - Root Canal Treatment'
          AND payment_date::date = '2025-01-20'::date
      );

      -- Payment: Cash 30000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        30000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT198 - Crowns-Zirconia',
        '2025-01-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT198 - Crowns-Zirconia'
          AND payment_date::date = '2025-01-20'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT199 | Patient: PRODONT418 | Date: 2025-01-28 | Total: 600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT199', 'PRODONT418';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-01-28, skipping invoice INVPRODONT199', 'PRODONT418';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        600,
        600,
        0,
        '2025-01-28'::date,
        now(),
        'INVPRODONT199'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT199'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT199' LIMIT 1;

      -- Payment: Cash 300 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT199 - Consultation',
        '2025-01-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT199 - Consultation'
          AND payment_date::date = '2025-01-28'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT199 - X RAY (RADIOGRAPH-RVG)',
        '2025-01-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT199 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-01-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT200 | Patient: PRODONT505 | Date: 2025-01-28 | Total: 15500
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT505' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT200', 'PRODONT505';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-01-28'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-01-28, skipping invoice INVPRODONT200', 'PRODONT505';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        15500,
        15500,
        0,
        '2025-01-28'::date,
        now(),
        'INVPRODONT200'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT200'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT200' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT200 - Consultation',
        '2025-01-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT200 - Consultation'
          AND payment_date::date = '2025-01-28'::date
      );

      -- Payment: Cash 5000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        5000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT200 - Root Canal Treatment',
        '2025-01-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT200 - Root Canal Treatment'
          AND payment_date::date = '2025-01-28'::date
      );

      -- Payment: Cash 10000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT200 - Crowns-Zirconia',
        '2025-01-28'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT200 - Crowns-Zirconia'
          AND payment_date::date = '2025-01-28'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT201 | Patient: PRODONT506 | Date: 2025-01-25 | Total: 40000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT506' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT201', 'PRODONT506';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-02-01'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-02-01, skipping invoice INVPRODONT201', 'PRODONT506';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        40000,
        40000,
        0,
        '2025-01-25'::date,
        now(),
        'INVPRODONT201'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT201'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT201' LIMIT 1;

      -- Payment: Cash 800 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        800,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT201 - Consultation',
        '2025-01-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT201 - Consultation'
          AND payment_date::date = '2025-01-25'::date
      );

      -- Payment: Cash 6000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT201 - Root Canal Treatment',
        '2025-01-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT201 - Root Canal Treatment'
          AND payment_date::date = '2025-01-25'::date
      );

      -- Payment: Cash 10000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT201 - Crowns-Zirconia',
        '2025-01-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT201 - Crowns-Zirconia'
          AND payment_date::date = '2025-01-25'::date
      );

      -- Payment: Cash 2000 for Oral Prophylaxis with Polishing
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT201 - Oral Prophylaxis with Polishing',
        '2025-01-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT201 - Oral Prophylaxis with Polishing'
          AND payment_date::date = '2025-01-25'::date
      );

      -- Payment: Cash 1200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1200,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT201 - X RAY (RADIOGRAPH-RVG)',
        '2025-01-25'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT201 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-01-25'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT202 | Patient: PRODONT447 | Date: 2025-02-13 | Total: 700
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT447' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT202', 'PRODONT447';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = NULL::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on None, skipping invoice INVPRODONT202', 'PRODONT447';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        700,
        700,
        0,
        '2025-02-13'::date,
        now(),
        'INVPRODONT202'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT202'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT202' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT202 - Consultation',
        '2025-02-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT202 - Consultation'
          AND payment_date::date = '2025-02-13'::date
      );

      -- Payment: Cash 200 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        200,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT202 - X RAY (RADIOGRAPH-RVG)',
        '2025-02-13'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT202 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-02-13'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT203 | Patient: PRODONT395 | Date: 2025-03-09 | Total: 6000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT395' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT203', 'PRODONT395';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-09'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-03-09, skipping invoice INVPRODONT203', 'PRODONT395';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        6000,
        6000,
        0,
        '2025-03-09'::date,
        now(),
        'INVPRODONT203'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT203'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT203' LIMIT 1;

      -- Payment: Cash 500 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT203 - Consultation',
        '2025-03-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT203 - Consultation'
          AND payment_date::date = '2025-03-09'::date
      );

      -- Payment: Cash 3000 for Packable / Bulk Fill Composite Restoration (3M)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        3000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT203 - Packable / Bulk Fill Composite Restoration (3M)',
        '2025-03-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT203 - Packable / Bulk Fill Composite Restoration (3M)'
          AND payment_date::date = '2025-03-09'::date
      );

      -- Payment: Cash 500 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT203 - X RAY (RADIOGRAPH-RVG)',
        '2025-03-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT203 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-03-09'::date
      );

      -- Payment: Cash 2000 for Subgingival Scaling
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT203 - Subgingival Scaling',
        '2025-03-09'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT203 - Subgingival Scaling'
          AND payment_date::date = '2025-03-09'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT204 | Patient: PRODONT508 | Date: 2025-03-11 | Total: 900
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT508' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT204', 'PRODONT508';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-11'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-03-11, skipping invoice INVPRODONT204', 'PRODONT508';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        900,
        900,
        0,
        '2025-03-11'::date,
        now(),
        'INVPRODONT204'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT204'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT204' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT204 - Consultation',
        '2025-03-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT204 - Consultation'
          AND payment_date::date = '2025-03-11'::date
      );

      -- Payment: UPI 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT204 - X RAY (RADIOGRAPH-RVG)',
        '2025-03-11'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT204 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-03-11'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT205 | Patient: PRODONT510 | Date: 2025-03-29 | Total: 3400
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT510' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT205', 'PRODONT510';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-03-29'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-03-29, skipping invoice INVPRODONT205', 'PRODONT510';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        3400,
        3400,
        0,
        '2025-03-29'::date,
        now(),
        'INVPRODONT205'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT205'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT205' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT205 - Consultation',
        '2025-03-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT205 - Consultation'
          AND payment_date::date = '2025-03-29'::date
      );

      -- Payment: Cash 300 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        300,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT205 - X RAY (RADIOGRAPH-RVG)',
        '2025-03-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT205 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-03-29'::date
      );

      -- Payment: Cash 2500 for SUPRA & SUB GINGIVAL SCALING
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT205 - SUPRA & SUB GINGIVAL SCALING',
        '2025-03-29'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT205 - SUPRA & SUB GINGIVAL SCALING'
          AND payment_date::date = '2025-03-29'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT207 | Patient: PRODONT512 | Date: 2025-04-10 | Total: 20600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT512' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT207', 'PRODONT512';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-04-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-04-10, skipping invoice INVPRODONT207', 'PRODONT512';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        20600,
        20600,
        0,
        '2025-04-10'::date,
        now(),
        'INVPRODONT207'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT207'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT207' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT207 - Consultation',
        '2025-04-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT207 - Consultation'
          AND payment_date::date = '2025-04-10'::date
      );

      -- Payment: Cash 6000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT207 - Root Canal Treatment',
        '2025-04-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT207 - Root Canal Treatment'
          AND payment_date::date = '2025-04-10'::date
      );

      -- Payment: Cash 10000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT207 - Crowns-Zirconia',
        '2025-04-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT207 - Crowns-Zirconia'
          AND payment_date::date = '2025-04-10'::date
      );

      -- Payment: Cash 4000 for Packable / Bulk Fill Composite Restoration (3M)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT207 - Packable / Bulk Fill Composite Restoration (3M)',
        '2025-04-10'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT207 - Packable / Bulk Fill Composite Restoration (3M)'
          AND payment_date::date = '2025-04-10'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT208 | Patient: PRODONT514 | Date: 2025-03-26 | Total: 45600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT514' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT208', 'PRODONT514';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-04-10'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-04-10, skipping invoice INVPRODONT208', 'PRODONT514';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        45600,
        45600,
        0,
        '2025-03-26'::date,
        now(),
        'INVPRODONT208'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT208'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT208' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT208 - Consultation',
        '2025-03-26'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT208 - Consultation'
          AND payment_date::date = '2025-03-26'::date
      );

      -- Payment: Cash 18000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        18000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT208 - Root Canal Treatment',
        '2025-03-26'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT208 - Root Canal Treatment'
          AND payment_date::date = '2025-03-26'::date
      );

      -- Payment: Cash 27000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        27000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT208 - Crowns-Zirconia',
        '2025-03-26'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT208 - Crowns-Zirconia'
          AND payment_date::date = '2025-03-26'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT209 | Patient: PRODONT492 | Date: 2025-05-03 | Total: 47000
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT492' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT209', 'PRODONT492';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-05-02'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-05-02, skipping invoice INVPRODONT209', 'PRODONT492';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        47000,
        47000,
        0,
        '2025-05-03'::date,
        now(),
        'INVPRODONT209'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT209'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT209' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT209 - Consultation',
        '2025-05-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT209 - Consultation'
          AND payment_date::date = '2025-05-03'::date
      );

      -- Payment: Cash 9000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        9000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT209 - Crowns-Zirconia',
        '2025-05-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT209 - Crowns-Zirconia'
          AND payment_date::date = '2025-05-03'::date
      );

      -- Payment: Cash 37000 for Implants
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        37000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT209 - Implants',
        '2025-05-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT209 - Implants'
          AND payment_date::date = '2025-05-03'::date
      );

      -- Payment: Cash 400 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        400,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT209 - X RAY (RADIOGRAPH-RVG)',
        '2025-05-03'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT209 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-05-03'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT210 | Patient: PRODONT515 | Date: 2025-05-05 | Total: 11600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT515' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT210', 'PRODONT515';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-05-05'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-05-05, skipping invoice INVPRODONT210', 'PRODONT515';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        11600,
        11600,
        0,
        '2025-05-05'::date,
        now(),
        'INVPRODONT210'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT210'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT210' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT210 - Consultation',
        '2025-05-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT210 - Consultation'
          AND payment_date::date = '2025-05-05'::date
      );

      -- Payment: Cash 10000 for Surgical Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        10000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT210 - Surgical Extraction',
        '2025-05-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT210 - Surgical Extraction'
          AND payment_date::date = '2025-05-05'::date
      );

      -- Payment: Cash 400 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        400,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT210 - X RAY (RADIOGRAPH-RVG)',
        '2025-05-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT210 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-05-05'::date
      );

      -- Payment: Cash 600 for Suture removal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT210 - Suture removal',
        '2025-05-05'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT210 - Suture removal'
          AND payment_date::date = '2025-05-05'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT211 | Patient: PRODONT516 | Date: 2025-06-08 | Total: 3700
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT516' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT211', 'PRODONT516';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-08'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-06-08, skipping invoice INVPRODONT211', 'PRODONT516';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        3700,
        3700,
        0,
        '2025-06-08'::date,
        now(),
        'INVPRODONT211'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT211'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT211' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT211 - Consultation',
        '2025-06-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT211 - Consultation'
          AND payment_date::date = '2025-06-08'::date
      );

      -- Payment: UPI 1000 for Curretage
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT211 - Curretage',
        '2025-06-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT211 - Curretage'
          AND payment_date::date = '2025-06-08'::date
      );

      -- Payment: UPI 600 for X RAY (RADIOGRAPH-RVG)
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT211 - X RAY (RADIOGRAPH-RVG)',
        '2025-06-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT211 - X RAY (RADIOGRAPH-RVG)'
          AND payment_date::date = '2025-06-08'::date
      );

      -- Payment: UPI 1500 for Crown removal
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        1500,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT211 - Crown removal',
        '2025-06-08'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT211 - Crown removal'
          AND payment_date::date = '2025-06-08'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT212 | Patient: PRODONT517 | Date: 2025-06-12 | Total: 120600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT517' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT212', 'PRODONT517';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-12'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-06-12, skipping invoice INVPRODONT212', 'PRODONT517';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        120600,
        120600,
        0,
        '2025-06-12'::date,
        now(),
        'INVPRODONT212'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT212'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT212' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT212 - Consultation',
        '2025-06-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT212 - Consultation'
          AND payment_date::date = '2025-06-12'::date
      );

      -- Payment: UPI 36000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        36000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT212 - Root Canal Treatment',
        '2025-06-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT212 - Root Canal Treatment'
          AND payment_date::date = '2025-06-12'::date
      );

      -- Payment: UPI 4000 for Tooth Extraction
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        4000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT212 - Tooth Extraction',
        '2025-06-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT212 - Tooth Extraction'
          AND payment_date::date = '2025-06-12'::date
      );

      -- Payment: UPI 80000 for DMLS CROWN
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        80000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT212 - DMLS CROWN',
        '2025-06-12'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT212 - DMLS CROWN'
          AND payment_date::date = '2025-06-12'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT213 | Patient: PRODONT418 | Date: 2025-06-17 | Total: 2600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT418' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT213', 'PRODONT418';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-17'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-06-17, skipping invoice INVPRODONT213', 'PRODONT418';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        2600,
        2600,
        0,
        '2025-06-17'::date,
        now(),
        'INVPRODONT213'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT213'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT213' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT213 - Consultation',
        '2025-06-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT213 - Consultation'
          AND payment_date::date = '2025-06-17'::date
      );

      -- Payment: UPI 0 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT213 - Follow-Up',
        '2025-06-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT213 - Follow-Up'
          AND payment_date::date = '2025-06-17'::date
      );

      -- Payment: UPI 2000 for Replacememt of crown under warranty ( BASE CHARGES
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT213 - Replacememt of crown under warranty ( BASE CHARGES )',
        '2025-06-17'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT213 - Replacememt of crown under warranty ( BASE CHARGES )'
          AND payment_date::date = '2025-06-17'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT214 | Patient: PRODONT518 | Date: 2025-06-20 | Total: 88300
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT518' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT214', 'PRODONT518';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-20'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-06-20, skipping invoice INVPRODONT214', 'PRODONT518';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        88300,
        88300,
        0,
        '2025-06-20'::date,
        now(),
        'INVPRODONT214'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT214'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT214' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Consultation',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Consultation'
          AND payment_date::date = '2025-06-20'::date
      );

      -- Payment: Cash 0 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        0,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Follow-Up',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Follow-Up'
          AND payment_date::date = '2025-06-20'::date
      );

      -- Payment: Cash 6000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        6000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Root Canal Treatment',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Root Canal Treatment'
          AND payment_date::date = '2025-06-20'::date
      );

      -- Payment: Cash 20000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        20000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Crowns-Zirconia',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Crowns-Zirconia'
          AND payment_date::date = '2025-06-20'::date
      );

      -- Payment: Cash 2500 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        2500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Resin Modified GIC Restoration',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Resin Modified GIC Restoration'
          AND payment_date::date = '2025-06-20'::date
      );

      -- Payment: Cash 500 for Follow-Up
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        500,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT214 - Follow-Up',
        '2025-06-20'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT214 - Follow-Up'
          AND payment_date::date = '2025-06-20'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT215 | Patient: PRODONT520 | Date: 2025-06-30 | Total: 51600
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT520' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT215', 'PRODONT520';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-06-30'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-06-30, skipping invoice INVPRODONT215', 'PRODONT520';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        51600,
        51600,
        0,
        '2025-06-30'::date,
        now(),
        'INVPRODONT215'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT215'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT215' LIMIT 1;

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT215 - Consultation',
        '2025-06-30'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT215 - Consultation'
          AND payment_date::date = '2025-06-30'::date
      );

      -- Payment: Cash 15000 for Root Canal Treatment
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        15000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT215 - Root Canal Treatment',
        '2025-06-30'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT215 - Root Canal Treatment'
          AND payment_date::date = '2025-06-30'::date
      );

      -- Payment: Cash 36000 for Crowns-Zirconia
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        36000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT215 - Crowns-Zirconia',
        '2025-06-30'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT215 - Crowns-Zirconia'
          AND payment_date::date = '2025-06-30'::date
      );

    END IF;
  END IF;

  -- Invoice: INVPRODONT216 | Patient: PRODONT521 | Date: 2025-07-21 | Total: 68800
  SELECT id INTO v_patient_id FROM public.patients WHERE legacy_patient_code = 'PRODONT521' LIMIT 1;

  IF v_patient_id IS NULL THEN
    RAISE WARNING 'Patient % not found, skipping invoice INVPRODONT216', 'PRODONT521';
  ELSE
    -- Find the linked visit (nearest to payment date)
    SELECT id INTO v_visit_id
    FROM public.visits
    WHERE patient_id = v_patient_id
      AND visit_date::date = '2025-07-21'::date
    LIMIT 1;

    IF v_visit_id IS NULL THEN
      RAISE WARNING 'Visit not found for patient % on 2025-07-21, skipping invoice INVPRODONT216', 'PRODONT521';
    ELSE
      -- Insert invoice
      INSERT INTO public.invoices (
        id, patient_id, visit_id,
        total_amount, amount_paid, balance_amount,
        invoice_date,
        created_at,
        legacy_bill_number
      )
      SELECT
        gen_random_uuid(),
        v_patient_id,
        v_visit_id,
        68800,
        68800,
        0,
        '2025-07-21'::date,
        now(),
        'INVPRODONT216'
      WHERE NOT EXISTS (
        SELECT 1 FROM public.invoices
        WHERE legacy_bill_number = 'INVPRODONT216'
      );

      SELECT id INTO v_invoice_id FROM public.invoices WHERE legacy_bill_number = 'INVPRODONT216' LIMIT 1;

      -- Payment: UPI 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT216 - Consultation',
        '2025-07-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT216 - Consultation'
          AND payment_date::date = '2025-07-21'::date
      );

      -- Payment: UPI 8000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'UPI'::payment_mode_type,
        'Migrated INVPRODONT216 - Resin Modified GIC Restoration',
        '2025-07-21'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT216 - Resin Modified GIC Restoration'
          AND payment_date::date = '2025-07-21'::date
      );

      -- Payment: Cash 600 for Consultation
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        600,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT216 - Consultation',
        '2025-07-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT216 - Consultation'
          AND payment_date::date = '2025-07-18'::date
      );

      -- Payment: Cash 8000 for Resin Modified GIC Restoration
      INSERT INTO public.payments (
        id, visit_id,
        amount_paid, payment_mode,
        notes,
        payment_date,
        created_at
      )
      SELECT
        gen_random_uuid(),
        v_visit_id,
        8000,
        'Cash'::payment_mode_type,
        'Migrated INVPRODONT216 - Resin Modified GIC Restoration',
        '2025-07-18'::date,
        now()
      WHERE NOT EXISTS (
        SELECT 1 FROM public.payments
        WHERE visit_id = v_visit_id
          AND notes = 'Migrated INVPRODONT216 - Resin Modified GIC Restoration'
          AND payment_date::date = '2025-07-18'::date
      );

    END IF;
  END IF;

END $$ LANGUAGE plpgsql;

-- Verification
SELECT
  (SELECT COUNT(*) FROM public.invoices
   WHERE created_at >= NOW() - INTERVAL '1 day') AS invoices_inserted_today,
  (SELECT COUNT(*) FROM public.payments
   WHERE created_at >= NOW() - INTERVAL '1 day') AS payments_inserted_today;
