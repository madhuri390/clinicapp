-- =============================================================
-- MIGRATION STEP 4: VISITS + TREATMENT PLANS  (52 visits, 153 treatment plans)
-- Run AFTER Step 3 (patients)
--
-- visits.status        = 'completed' for all historical records
-- treatment_plans.status = 'completed' for all historical records
-- Doctor: Dr. Surya teja (looked up by first_name ILIKE '%Surya%')
-- Idempotent: re-running skips already-inserted rows
-- =============================================================

-- 4A: Schema prep — add legacy_bill_number to invoices (used in Step 5)
ALTER TABLE public.invoices ADD COLUMN IF NOT EXISTS legacy_bill_number TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS invoices_legacy_bill_number_idx
  ON public.invoices (legacy_bill_number)
  WHERE legacy_bill_number IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- 4B. Insert visits (52 rows — one per unique patient + treatment date)
-- ─────────────────────────────────────────────────────────────
WITH visit_src (legacy_code, visit_dt) AS (
  VALUES
  ('PRODONT112-B', '2021-12-13'),
  ('PRODONT113', '2021-12-17'),
  ('PRODONT114', '2021-12-19'),
  ('PRODONT115', '2021-12-23'),
  ('PRODONT116', '2021-12-29'),
  ('PRODONT118', '2022-01-27'),
  ('PRODONT120', '2022-01-28'),
  ('PRODONT121', '2022-01-29'),
  ('PRODONT122', '2022-01-31'),
  ('PRODONT123', '2022-02-01'),
  ('PRODONT128', '2022-02-06'),
  ('PRODONT129', '2022-02-17'),
  ('PRODONT132', '2022-02-11'),
  ('PRODONT133', '2022-02-11'),
  ('PRODONT136', '2022-03-22'),
  ('PRODONT160', '2022-03-29'),
  ('PRODONT171', '2022-05-11'),
  ('PRODONT174', '2022-04-10'),
  ('PRODONT185', '2023-01-03'),
  ('PRODONT194', '2022-10-28'),
  ('PRODONT196', '2022-07-31'),
  ('PRODONT197', '2022-06-02'),
  ('PRODONT201', '2022-06-03'),
  ('PRODONT202', '2022-06-13'),
  ('PRODONT206', '2022-05-28'),
  ('PRODONT208', '2022-05-20'),
  ('PRODONT209', '2022-05-21'),
  ('PRODONT211', '2022-09-26'),
  ('PRODONT233', '2022-07-29'),
  ('PRODONT262', '2022-09-17'),
  ('PRODONT262', '2022-09-10'),
  ('PRODONT263', '2022-09-11'),
  ('PRODONT264', '2022-09-18'),
  ('PRODONT269', '2022-09-24'),
  ('PRODONT270', '2022-09-22'),
  ('PRODONT274', '2022-09-24'),
  ('PRODONT275', '2022-09-24'),
  ('PRODONT277', '2022-10-06'),
  ('PRODONT280', '2022-10-21'),
  ('PRODONT286', '2022-11-02'),
  ('PRODONT287', '2022-11-03'),
  ('PRODONT289', '2022-11-12'),
  ('PRODONT290', '2023-01-26'),
  ('PRODONT292', '2022-11-24'),
  ('PRODONT293', '2022-11-24'),
  ('PRODONT296', '2022-12-16'),
  ('PRODONT304', '2023-01-08'),
  ('PRODONT305', '2023-01-29'),
  ('PRODONT305', '2023-01-14'),
  ('PRODONT308', '2023-01-13'),
  ('PRODONT310', '2023-01-30'),
  ('PRODONT316', '2023-02-07')
),
doctor_id_lookup AS (
  SELECT id FROM public.doctors
  WHERE first_name ILIKE '%Surya%'
  LIMIT 1
)
INSERT INTO public.visits (patient_id, doctor_id, visit_date, status, created_at, updated_at)
SELECT
  p.id,
  d.id,
  vs.visit_dt::timestamptz,
  'complete'::visit_status,
  vs.visit_dt::timestamptz,
  now()
FROM visit_src vs
JOIN public.patients p ON p.legacy_patient_code = vs.legacy_code
CROSS JOIN doctor_id_lookup d
WHERE NOT EXISTS (
  SELECT 1 FROM public.visits v
  WHERE v.patient_id = p.id
    AND v.visit_date::date = vs.visit_dt::date
);

-- ─────────────────────────────────────────────────────────────
-- 4C. Insert treatment plans (153 rows — deduplication via NOT EXISTS)
-- ─────────────────────────────────────────────────────────────
WITH tp_src (legacy_code, visit_dt, treatment_name, teeth, description, total_cost) AS (
  VALUES
  ('PRODONT112-B', '2021-12-13', 'X RAY', '47, 36', NULL, 300),
  ('PRODONT112-B', '2021-12-13', 'Consultation', '18, 17, 16, 15, 14, 13, 12, 11, 48, 47, 46, 45, 44, 43, 42, 41, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38', NULL, 300),
  ('PRODONT112-B', '2021-12-13', 'Root Canal Treatment', '47, 36', NULL, 4000),
  ('PRODONT112-B', '2021-12-13', 'Surgical Extraction', '48', NULL, 5500),
  ('PRODONT112-B', '2021-12-13', 'Crowns', '47, 36', NULL, 9000),
  ('PRODONT112-B', '2021-12-13', 'Scaling', NULL, NULL, 2500),
  ('PRODONT113', '2021-12-17', 'Surgical Extraction', '4A', NULL, 500),
  ('PRODONT114', '2021-12-19', 'Composites', '11, 21', NULL, -500),
  ('PRODONT114', '2021-12-19', 'Fillings', '45', NULL, 500),
  ('PRODONT114', '2021-12-19', 'Surgical Extraction', '28', NULL, 4000),
  ('PRODONT114', '2021-12-19', 'Composites', '11, 21', NULL, -500),
  ('PRODONT114', '2021-12-19', 'Surgical Extraction', '28', NULL, 4000),
  ('PRODONT114', '2021-12-19', 'Surgical Extraction', '28', NULL, 4000),
  ('PRODONT114', '2021-12-19', 'Fillings', '45', NULL, 500),
  ('PRODONT114', '2021-12-19', 'Fillings', '45', NULL, 500),
  ('PRODONT114', '2021-12-19', 'Fillings', '45', NULL, 500),
  ('PRODONT114', '2021-12-19', 'Composites', '11, 21', NULL, -500),
  ('PRODONT114', '2021-12-19', 'Surgical Extraction', '28', NULL, 4000),
  ('PRODONT114', '2021-12-19', 'Composites', '11, 21', NULL, -500),
  ('PRODONT115', '2021-12-23', 'Surgical Extraction', '48', NULL, 6000),
  ('PRODONT115', '2021-12-23', 'Consultation', NULL, 'No consultation charged', 0),
  ('PRODONT115', '2021-12-23', 'X RAY', '48', NULL, 250),
  ('PRODONT115', '2021-12-23', 'X RAY', '48', NULL, 300),
  ('PRODONT116', '2021-12-29', 'Scaling', NULL, NULL, 1500),
  ('PRODONT118', '2022-01-27', 'X RAY', NULL, NULL, 300),
  ('PRODONT118', '2022-01-27', 'Consultation', NULL, NULL, 300),
  ('PRODONT118', '2022-01-27', 'Composites', NULL, NULL, 2000),
  ('PRODONT120', '2022-01-28', 'Scaling', NULL, NULL, 1500),
  ('PRODONT120', '2022-01-28', 'polishing', NULL, NULL, 600),
  ('PRODONT121', '2022-01-29', 'X RAY', '1A, 2A', NULL, 300),
  ('PRODONT121', '2022-01-29', 'Pedodontic consult', '1A', NULL, 600),
  ('PRODONT121', '2022-01-29', 'Trauma-Extraction Pedodontic', '1A, 2A', NULL, 1500),
  ('PRODONT122', '2022-01-31', 'Fillings', '17, 46, 27, 36', NULL, 1000),
  ('PRODONT123', '2022-02-01', 'Crowns', '46', NULL, 6000),
  ('PRODONT128', '2022-02-06', 'X RAY', NULL, NULL, 300),
  ('PRODONT128', '2022-02-06', 'Consultation', '26', NULL, 400),
  ('PRODONT129', '2022-02-17', 'Crowns - Zirconia', '16,15,27,46', 'Dentcare: Zirconia : Job no: AC6362', 9000),
  ('PRODONT129', '2022-02-17', 'X RAY', '16,46,27', NULL, 300),
  ('PRODONT129', '2022-02-17', 'Fillings', '27,46,16', NULL, 1500),
  ('PRODONT129', '2022-02-17', 'Single Sitting Root Canal Treatment', NULL, NULL, 6000),
  ('PRODONT129', '2022-02-17', 'Consultation', NULL, NULL, 300),
  ('PRODONT132', '2022-02-11', 'X RAY', NULL, NULL, 300),
  ('PRODONT132', '2022-02-11', 'Crowns - Zirconia', '36', NULL, 8000),
  ('PRODONT132', '2022-02-11', 'Consultation', NULL, NULL, 300),
  ('PRODONT132', '2022-02-11', 'Root Canal Treatment', '36', NULL, 6000),
  ('PRODONT133', '2022-02-11', 'Scaling', NULL, NULL, 1500),
  ('PRODONT133', '2022-02-11', 'Consultation', NULL, NULL, 300),
  ('PRODONT133', '2022-02-11', 'X RAY', NULL, NULL, 300),
  ('PRODONT133', '2022-02-11', 'Polishing', NULL, NULL, 500),
  ('PRODONT136', '2022-03-22', 'Crowns - Zirconia', '26, 27', NULL, 8000),
  ('PRODONT136', '2022-03-22', 'Root Canal Treatment', '26, 27', NULL, 5000),
  ('PRODONT136', '2022-03-22', 'Consultation', NULL, NULL, 600),
  ('PRODONT160', '2022-03-29', 'X RAY', '18, 17, 16', NULL, 500),
  ('PRODONT160', '2022-03-29', 'Root Canal Treatment', '17, 16', NULL, 5000),
  ('PRODONT171', '2022-05-11', 'Border moulding and secondary impressions', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Teeth setting & try in', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Acrylisation, Finishing & polishing', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Special tray fabrication', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Impressions:', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Jaw relations', NULL, NULL, 0),
  ('PRODONT171', '2022-05-11', 'Denture- Dentcare- Flex ( upper )', '17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27', NULL, 15000),
  ('PRODONT174', '2022-04-10', 'Consultation', NULL, NULL, 150),
  ('PRODONT174', '2022-04-10', 'X RAY', NULL, NULL, 150),
  ('PRODONT174', '2022-04-10', 'X RAY', NULL, NULL, 150),
  ('PRODONT174', '2022-04-10', 'SPECIALIST CONSULT(PEDO)', NULL, NULL, 250),
  ('PRODONT185', '2023-01-03', 'Complete Dentures -BPS , (DENTCARE)', NULL, NULL, 40000),
  ('PRODONT194', '2022-10-28', 'Fillings', NULL, NULL, 1500),
  ('PRODONT196', '2022-07-31', 'Root Canal Treatment', '46, 26', NULL, 4500),
  ('PRODONT196', '2022-07-31', 'Fillings', '16, 47, 37', NULL, 1500),
  ('PRODONT196', '2022-07-31', 'Surgical Extraction', '25', NULL, 4000),
  ('PRODONT196', '2022-07-31', 'Crowns - Zirconia', '46, 26', NULL, 8000),
  ('PRODONT197', '2022-06-02', 'Fractured Tooth -Composite restoration', '36', NULL, 1300),
  ('PRODONT197', '2022-06-02', 'Root Canal Treatment', '25', NULL, 4000),
  ('PRODONT197', '2022-06-02', 'Scaling', NULL, NULL, 1500),
  ('PRODONT197', '2022-06-02', 'Scaling', NULL, NULL, 1500),
  ('PRODONT197', '2022-06-02', 'Fractured Tooth -Composite restoration', '36', NULL, 1300),
  ('PRODONT197', '2022-06-02', 'Re-root Canal Treatment', '24', NULL, 4000),
  ('PRODONT197', '2022-06-02', 'Crowns - Zirconia', '24, 25', NULL, 8000),
  ('PRODONT197', '2022-06-02', 'Fillings', '27', NULL, 1300),
  ('PRODONT197', '2022-06-02', 'Root Canal Treatment', '25', NULL, 4000),
  ('PRODONT197', '2022-06-02', 'Re-root Canal Treatment', '24', NULL, 4000),
  ('PRODONT197', '2022-06-02', 'Crowns - Zirconia', '24, 25', NULL, 8000),
  ('PRODONT197', '2022-06-02', 'Fillings', '27', NULL, 1300),
  ('PRODONT201', '2022-06-03', 'Consultation', NULL, NULL, 500),
  ('PRODONT201', '2022-06-03', 'Root Canal Treatment', '25', NULL, 4000),
  ('PRODONT201', '2022-06-03', 'Crowns - Zirconia', '25', NULL, 8000),
  ('PRODONT202', '2022-06-13', 'Root Canal Treatment', '37', NULL, 4500),
  ('PRODONT202', '2022-06-13', 'Crowns - Zirconia', '37', NULL, 8000),
  ('PRODONT202', '2022-06-13', 'Surgical Extraction', '38', NULL, 4000),
  ('PRODONT206', '2022-05-28', 'Crowns - Zirconia', '46', NULL, 8000),
  ('PRODONT206', '2022-05-28', 'Root Canal Treatment', '46', NULL, 4500),
  ('PRODONT208', '2022-05-20', 'Consultation', NULL, NULL, 300),
  ('PRODONT208', '2022-05-20', 'X RAY', NULL, NULL, 200),
  ('PRODONT209', '2022-05-21', 'Scaling', NULL, NULL, 1500),
  ('PRODONT209', '2022-05-21', 'X RAY', NULL, NULL, 200),
  ('PRODONT211', '2022-09-26', 'Dental Implant', '35', NULL, 23000),
  ('PRODONT211', '2022-09-26', 'Crowns - Zirconia', NULL, NULL, 10000),
  ('PRODONT233', '2022-07-29', 'Clear Aligners- PREMIUM + ORTHODONTICS', NULL, NULL, 180000),
  ('PRODONT233', '2022-07-29', 'Clear Aligners- PREMIUM + ORTHODONTICS', NULL, NULL, 180000),
  ('PRODONT233', '2022-07-29', 'Clear Aligners- PREMIUM + ORTHODONTICS', NULL, NULL, 180000),
  ('PRODONT262', '2022-09-17', 'Consultation', NULL, NULL, 500),
  ('PRODONT262', '2022-09-17', 'X RAY', NULL, NULL, 0),
  ('PRODONT262', '2022-09-10', 'Surgical Extraction', '28,38', 'Good prognosis. Follow up on 10-09-2022', 5500),
  ('PRODONT263', '2022-09-11', 'Polishing', NULL, NULL, 500),
  ('PRODONT263', '2022-09-11', 'Consultation', NULL, NULL, 300),
  ('PRODONT263', '2022-09-11', 'Scaling', NULL, NULL, 1500),
  ('PRODONT264', '2022-09-18', 'Scaling', NULL, NULL, 2500),
  ('PRODONT264', '2022-09-18', 'X RAY', '11, 21', NULL, 300),
  ('PRODONT264', '2022-09-18', 'EMAX', '11, 21', NULL, 18000),
  ('PRODONT264', '2022-09-18', 'Intra Oral Scan', NULL, NULL, 1500),
  ('PRODONT269', '2022-09-24', 'Consultation', NULL, NULL, 500),
  ('PRODONT269', '2022-09-24', 'Surgical Extraction', '18', NULL, 5000),
  ('PRODONT269', '2022-09-24', 'X RAY', NULL, NULL, 0),
  ('PRODONT270', '2022-09-22', 'Scaling', NULL, NULL, 1500),
  ('PRODONT270', '2022-09-22', 'Composites', '15', NULL, 1500),
  ('PRODONT270', '2022-09-22', 'Polishing', NULL, NULL, 0),
  ('PRODONT270', '2022-09-22', 'Crowns - Zirconia', '47', NULL, 9000),
  ('PRODONT274', '2022-09-24', 'X RAY', NULL, NULL, 200),
  ('PRODONT274', '2022-09-24', 'Consultation', NULL, NULL, 300),
  ('PRODONT275', '2022-09-24', 'X RAY', NULL, NULL, 200),
  ('PRODONT275', '2022-09-24', 'Consultation', NULL, NULL, 300),
  ('PRODONT277', '2022-10-06', 'Consultation', NULL, NULL, 300),
  ('PRODONT277', '2022-10-06', 'X RAY', NULL, NULL, 200),
  ('PRODONT280', '2022-10-21', 'Surgical Extraction', '48', NULL, 5500),
  ('PRODONT280', '2022-10-21', 'Surgical Extraction', '18', NULL, 5000),
  ('PRODONT286', '2022-11-02', 'Cavity Filling', '17, 16, 47, 26, 27, 37', NULL, -1500),
  ('PRODONT286', '2022-11-02', 'X RAY', NULL, NULL, 500),
  ('PRODONT286', '2022-11-02', 'Consultation', NULL, NULL, 500),
  ('PRODONT286', '2022-11-02', 'Scaling', NULL, NULL, 1500),
  ('PRODONT287', '2022-11-03', 'Root Canal Treatment', '36', NULL, 5000),
  ('PRODONT287', '2022-11-03', 'Crowns - Zirconia', '36', NULL, 9000),
  ('PRODONT289', '2022-11-12', 'Surgical Extraction', NULL, NULL, 4000),
  ('PRODONT289', '2022-11-12', 'Root Canal Treatment', '11, 23', NULL, 4000),
  ('PRODONT289', '2022-11-12', 'Crowns - Zirconia', '11, 21, 22, 23', NULL, 6000),
  ('PRODONT290', '2023-01-26', 'Braces', '18, 17, 16, 15, 14, 13, 12, 11, 48, 47, 46, 45, 44, 43, 42, 41, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38', 'PAID 40000 VIA GPAY REST 48000 TO BE PAID IN 8 INSTALLMENT FROM FEBRUARY', 88000),
  ('PRODONT292', '2022-11-24', 'Polishing', NULL, NULL, 500),
  ('PRODONT292', '2022-11-24', 'Scaling', NULL, NULL, 1500),
  ('PRODONT293', '2022-11-24', 'Scaling', NULL, NULL, 1500),
  ('PRODONT293', '2022-11-24', 'Polishing', NULL, NULL, 500),
  ('PRODONT296', '2022-12-16', 'Root Canal Treatment', '17, 16', NULL, 4500),
  ('PRODONT296', '2022-12-16', 'Crowns - Zirconia', NULL, NULL, 8000),
  ('PRODONT304', '2023-01-08', 'Polishing', NULL, NULL, 0),
  ('PRODONT304', '2023-01-08', 'Fractured Tooth -Composite restoration', NULL, NULL, 3500),
  ('PRODONT304', '2023-01-08', 'Scaling', NULL, NULL, 1500),
  ('PRODONT305', '2023-01-29', 'Crowns - Zirconia', '26', NULL, 7500),
  ('PRODONT305', '2023-01-14', 'Cavity Filling', '16, 46', NULL, 2000),
  ('PRODONT305', '2023-01-29', 'Cavity Filling', '16, 46', NULL, 2000),
  ('PRODONT308', '2023-01-13', 'Dental Implant', NULL, NULL, 34000),
  ('PRODONT308', '2023-01-13', 'Surgical Extraction', NULL, NULL, 1000),
  ('PRODONT310', '2023-01-30', 'Pulpectomy - Pediatric(incl crown)', NULL, NULL, 7000),
  ('PRODONT316', '2023-02-07', 'Root Canal Treatment', NULL, NULL, 4500),
  ('PRODONT316', '2023-02-07', 'Crowns - Zirconia', NULL, NULL, 8000),
  ('PRODONT316', '2023-02-07', 'Composites', NULL, NULL, 0)
)
INSERT INTO public.treatment_plans (visit_id, treatment_name, teeth, description, total_cost, status, created_at, updated_at)
SELECT
  v.id,
  ts.treatment_name,
  ts.teeth,
  ts.description,
  ts.total_cost,
  'planned'::treatment_status,
  v.visit_date,
  now()
FROM tp_src ts
JOIN public.patients p ON p.legacy_patient_code = ts.legacy_code
JOIN public.visits v   ON v.patient_id = p.id AND v.visit_date::date = ts.visit_dt::date
WHERE NOT EXISTS (
  SELECT 1 FROM public.treatment_plans tp
  WHERE tp.visit_id = v.id
    AND tp.treatment_name = ts.treatment_name
    AND COALESCE(tp.teeth, '') = COALESCE(ts.teeth, '')
);

-- ─────────────────────────────────────────────────────────────
-- Verification
-- ─────────────────────────────────────────────────────────────
SELECT
  (SELECT COUNT(*) FROM public.visits v
   JOIN public.patients p ON p.id = v.patient_id
   WHERE p.legacy_patient_code IS NOT NULL) AS migrated_visits,
  (SELECT COUNT(*) FROM public.treatment_plans tp
   JOIN public.visits v ON v.id = tp.visit_id
   JOIN public.patients p ON p.id = v.patient_id
   WHERE p.legacy_patient_code IS NOT NULL) AS migrated_treatment_plans;
