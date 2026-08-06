-- =============================================================
-- MIGRATION STEP 5: INVOICES + PAYMENTS  (54 invoices, 50 payments)
-- Run AFTER Step 4 (visits + treatment plans)
--
-- Payment mode mapping: Cash→Cash, Google Pay→UPI, NEFT→UPI
-- All invoices are set as fully paid (amount_paid = total_amount, balance = 0).
-- total_amount reflects the actual amount collected after any discount:
--   Bill #28 (PRODONT233): 180000 → 150000 (30000 discount)
--   Bill #51 (PRODONT290): 88000  → 40000  (first installment only, per clinic records)
-- Bills #8, #25, #26, #48 have no payment record — marked paid at face value.
-- Idempotent: invoices use ON CONFLICT on legacy_bill_number (partial unique index)
--             payments: NOT EXISTS check on (visit_id, notes)
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- 5A. Insert invoices (all fully paid, total = actual collected amount)
-- ─────────────────────────────────────────────────────────────
WITH inv_src (legacy_code, bill_no, bill_date, total_amount) AS (
  VALUES
  ('PRODONT112-B', '1',  '2021-12-13 14:50:45', 35400),
  ('PRODONT113',   '2',  '2021-12-17 00:00:00',   500),
  ('PRODONT114',   '3',  '2021-12-19 00:00:00',  6000),
  ('PRODONT114',   '4',  '2021-12-19 00:00:00',  6000),
  ('PRODONT114',   '5',  '2021-12-19 00:00:00',  6000),
  ('PRODONT114',   '6',  '2021-12-19 00:00:00',  6000),
  ('PRODONT115',   '7',  '2021-12-23 14:23:48',  6500),
  ('PRODONT116',   '8',  '2021-12-29 14:30:05',  1500),  -- no payment row; marked paid at face value
  ('PRODONT118',   '9',  '2022-01-27 13:08:25',  2600),
  ('PRODONT120',   '10', '2022-01-28 14:49:12',  2100),
  ('PRODONT121',   '11', '2022-01-29 00:00:00',  4200),
  ('PRODONT122',   '12', '2022-01-31 11:28:37',  4000),
  ('PRODONT123',   '13', '2022-02-01 13:40:02',  6000),
  ('PRODONT128',   '14', '2022-02-06 09:26:37',   700),
  ('PRODONT133',   '15', '2022-02-11 00:00:00',  2600),
  ('PRODONT132',   '16', '2022-02-11 09:10:21', 14600),
  ('PRODONT129',   '17', '2022-02-17 03:53:08', 47700),
  ('PRODONT136',   '18', '2022-03-22 00:00:00', 26600),
  ('PRODONT160',   '19', '2022-03-29 00:00:00', 10500),
  ('PRODONT174',   '20', '2022-04-10 14:06:46',   700),
  ('PRODONT171',   '21', '2022-05-11 00:00:00', 15000),
  ('PRODONT208',   '22', '2022-05-20 14:45:36',   500),
  ('PRODONT209',   '23', '2022-05-21 00:00:00',  1700),
  ('PRODONT206',   '24', '2022-05-28 00:00:00', 12500),
  ('PRODONT201',   '25', '2022-06-03 12:16:25', 12500),  -- no payment row; marked paid at face value
  ('PRODONT197',   '26', '2022-06-13 14:03:03', 28100),  -- no payment row; marked paid at face value
  ('PRODONT202',   '27', '2022-06-13 14:09:33', 16500),
  ('PRODONT233',   '28', '2022-07-29 00:00:00',150000),  -- discounted from 180000; payment was 150000
  ('PRODONT196',   '29', '2022-07-31 00:00:00', 33500),
  ('PRODONT262',   '30', '2022-09-10 09:38:33', 11500),
  ('PRODONT263',   '31', '2022-09-11 00:00:00',  2300),
  ('PRODONT262',   '32', '2022-09-17 00:00:00',   500),
  ('PRODONT264',   '33', '2022-09-18 08:04:10', 40600),
  ('PRODONT270',   '34', '2022-09-22 00:00:00', 12000),
  ('PRODONT269',   '35', '2022-09-24 06:24:18',  5500),
  ('PRODONT275',   '36', '2022-09-24 15:07:42',   500),
  ('PRODONT274',   '37', '2022-09-24 00:00:00',   500),
  ('PRODONT211',   '38', '2022-09-26 13:36:04', 33000),
  ('PRODONT277',   '39', '2022-10-06 00:00:00',   500),
  ('PRODONT280',   '40', '2022-10-21 12:49:51', 10500),
  ('PRODONT194',   '41', '2022-10-28 00:00:00',  1500),
  ('PRODONT286',   '42', '2022-11-02 08:11:41',  8500),
  ('PRODONT287',   '43', '2022-11-03 00:00:00', 14000),
  ('PRODONT289',   '44', '2022-11-12 00:00:00', 36000),
  ('PRODONT296',   '45', '2022-12-16 13:06:25', 17000),
  ('PRODONT185',   '46', '2023-01-03 00:00:00', 40000),
  ('PRODONT304',   '47', '2023-01-08 15:50:50',  4500),
  ('PRODONT304',   '48', '2023-01-08 15:52:02',   500),  -- no payment row; marked paid at face value
  ('PRODONT308',   '49', '2023-01-13 00:00:00', 35000),
  ('PRODONT305',   '50', '2023-01-14 06:18:23',  4000),
  ('PRODONT290',   '51', '2023-01-26 08:20:57', 40000),  -- installment: 40000 collected (was 88000)
  ('PRODONT305',   '52', '2023-01-29 00:00:00', 11500),
  ('PRODONT310',   '53', '2023-01-30 00:00:00',  7000),
  ('PRODONT316',   '54', '2023-02-07 00:00:00', 12500)
)
INSERT INTO public.invoices (patient_id, visit_id, total_amount, amount_paid, balance_amount, invoice_date, legacy_bill_number)
SELECT
  p.id,
  v.id,
  src.total_amount::numeric,
  src.total_amount::numeric,   -- fully paid
  0,                           -- zero balance
  src.bill_date::timestamp,
  'BILL-' || src.legacy_code || '-' || src.bill_no
FROM inv_src src
JOIN public.patients p ON p.legacy_patient_code = src.legacy_code
LEFT JOIN public.visits v ON v.patient_id = p.id AND v.visit_date::date = src.bill_date::date
ON CONFLICT (legacy_bill_number) WHERE legacy_bill_number IS NOT NULL DO NOTHING;

-- ─────────────────────────────────────────────────────────────
-- 5B. Insert payments (linked directly to visits)
-- ─────────────────────────────────────────────────────────────
WITH pay_src (legacy_code, visit_dt, receipt_dt, amount, mode, note) AS (
  VALUES
  ('PRODONT112-B', '2021-12-13', '2021-12-14 07:07:56', 35400, 'Cash', 'Migrated from PRODONT bill #1'),
  ('PRODONT113',   '2021-12-17', '2021-12-17 00:00:00',   500, 'Cash', 'Migrated from PRODONT bill #2'),
  ('PRODONT114',   '2021-12-19', '2021-12-19 00:00:00',  6000, 'Cash', 'Migrated from PRODONT bill #6'),
  ('PRODONT114',   '2021-12-19', '2021-12-19 00:00:00',  6000, 'Cash', 'Migrated from PRODONT bill #5'),
  ('PRODONT114',   '2021-12-19', '2021-12-19 00:00:00',  6000, 'Cash', 'Migrated from PRODONT bill #4'),
  ('PRODONT114',   '2021-12-19', '2021-12-19 00:00:00',  6000, 'Cash', 'Migrated from PRODONT bill #3'),
  ('PRODONT115',   '2021-12-23', '2021-12-23 14:24:06',  6500, 'Cash', 'Migrated from PRODONT bill #7'),
  ('PRODONT118',   '2022-01-27', '2022-01-27 13:08:37',  2600, 'Cash', 'Migrated from PRODONT bill #9'),
  ('PRODONT120',   '2022-01-28', '2022-01-28 14:49:18',  2100, 'Cash', 'Migrated from PRODONT bill #10'),
  ('PRODONT121',   '2022-01-29', '2022-01-29 00:00:00',  4200, 'Cash', 'Migrated from PRODONT bill #11'),
  ('PRODONT122',   '2022-01-31', '2022-01-31 11:28:53',  4000, 'Cash', 'Migrated from PRODONT bill #12'),
  ('PRODONT123',   '2022-02-01', '2022-02-01 13:40:27',  6000, 'Cash', 'Migrated from PRODONT bill #13'),
  ('PRODONT128',   '2022-02-06', '2022-02-06 09:26:41',   700, 'Cash', 'Migrated from PRODONT bill #14'),
  ('PRODONT129',   '2022-02-17', '2022-02-17 03:53:23', 47700, 'Cash', 'Migrated from PRODONT bill #17'),
  ('PRODONT132',   '2022-02-11', '2022-02-11 09:10:39', 14600, 'Cash', 'Migrated from PRODONT bill #16'),
  ('PRODONT133',   '2022-02-11', '2022-02-11 00:00:00',  2600, 'Cash', 'Migrated from PRODONT bill #15'),
  ('PRODONT136',   '2022-03-22', '2022-03-22 00:00:00', 26600, 'Cash', 'Migrated from PRODONT bill #18'),
  ('PRODONT160',   '2022-03-29', '2022-03-29 00:00:00', 10500, 'UPI',  'Migrated from PRODONT bill #19'),
  ('PRODONT171',   '2022-05-11', '2022-05-11 00:00:00', 15000, 'UPI',  'Migrated from PRODONT bill #21'),
  ('PRODONT174',   '2022-04-10', '2022-04-10 14:07:33',   700, 'UPI',  'Migrated from PRODONT bill #20'),
  ('PRODONT185',   '2023-01-03', '2023-01-03 00:00:00', 40000, 'UPI',  'Migrated from PRODONT bill #46'),
  ('PRODONT194',   '2022-10-28', '2022-10-28 00:00:00',  1500, 'Cash', 'Migrated from PRODONT bill #41'),
  ('PRODONT196',   '2022-07-31', '2022-07-31 00:00:00', 33500, 'Cash', 'Migrated from PRODONT bill #29'),
  ('PRODONT202',   '2022-06-13', '2022-06-13 14:09:55', 16500, 'Cash', 'Migrated from PRODONT bill #27'),
  ('PRODONT206',   '2022-05-28', '2022-05-28 00:00:00', 12500, 'Cash', 'Migrated from PRODONT bill #24'),
  ('PRODONT208',   '2022-05-20', '2022-05-20 14:45:52',   500, 'UPI',  'Migrated from PRODONT bill #22'),
  ('PRODONT209',   '2022-05-21', '2022-05-21 00:00:00',  1700, 'Cash', 'Migrated from PRODONT bill #23'),
  ('PRODONT211',   '2022-09-26', '2022-09-26 13:36:09', 33000, 'Cash', 'Migrated from PRODONT bill #38'),
  ('PRODONT233',   '2022-07-29', '2022-07-29 00:00:00',150000, 'UPI',  'Migrated from PRODONT bill #28'),
  ('PRODONT262',   '2022-09-17', '2022-09-17 00:00:00',   500, 'Cash', 'Migrated from PRODONT bill #32'),
  ('PRODONT262',   '2022-09-10', '2022-09-10 09:38:44', 11500, 'Cash', 'Migrated from PRODONT bill #30'),
  ('PRODONT263',   '2022-09-11', '2022-09-11 00:00:00',  2300, 'Cash', 'Migrated from PRODONT bill #31'),
  ('PRODONT264',   '2022-09-18', '2022-09-18 08:04:23', 40600, 'Cash', 'Migrated from PRODONT bill #33'),
  ('PRODONT269',   '2022-09-24', '2022-09-24 06:24:23',  5500, 'Cash', 'Migrated from PRODONT bill #35'),
  ('PRODONT270',   '2022-09-22', '2022-09-22 00:00:00', 12000, 'Cash', 'Migrated from PRODONT bill #34'),
  ('PRODONT274',   '2022-09-24', '2022-09-24 00:00:00',   500, 'Cash', 'Migrated from PRODONT bill #37'),
  ('PRODONT275',   '2022-09-24', '2022-09-24 15:07:47',   500, 'Cash', 'Migrated from PRODONT bill #36'),
  ('PRODONT277',   '2022-10-06', '2022-10-06 00:00:00',   500, 'Cash', 'Migrated from PRODONT bill #39'),
  ('PRODONT280',   '2022-10-21', '2022-10-17 12:50:37', 10500, 'UPI',  'Migrated from PRODONT bill #40'),
  ('PRODONT286',   '2022-11-02', '2022-11-02 08:12:05',  8500, 'Cash', 'Migrated from PRODONT bill #42'),
  ('PRODONT287',   '2022-11-03', '2022-11-03 00:00:00', 14000, 'Cash', 'Migrated from PRODONT bill #43'),
  ('PRODONT289',   '2022-11-12', '2022-11-12 00:00:00', 36000, 'Cash', 'Migrated from PRODONT bill #44'),
  ('PRODONT290',   '2023-01-26', '2023-01-26 08:21:29', 40000, 'UPI',  'Migrated from PRODONT bill #51'),
  ('PRODONT296',   '2022-12-16', '2022-12-16 13:06:29', 17000, 'Cash', 'Migrated from PRODONT bill #45'),
  ('PRODONT304',   '2023-01-08', '2023-01-08 15:52:26',  4500, 'UPI',  'Migrated from PRODONT bill #47'),
  ('PRODONT305',   '2023-01-29', '2023-01-29 00:00:00', 11500, 'UPI',  'Migrated from PRODONT bill #52'),
  ('PRODONT305',   '2023-01-14', '2023-01-14 06:19:12',  4000, 'Cash', 'Migrated from PRODONT bill #50'),
  ('PRODONT308',   '2023-01-13', '2023-01-13 00:00:00', 35000, 'Cash', 'Migrated from PRODONT bill #49'),
  ('PRODONT310',   '2023-01-30', '2023-01-30 00:00:00',  7000, 'UPI',  'Migrated from PRODONT bill #53'),
  ('PRODONT316',   '2023-02-07', '2023-02-07 00:00:00', 12500, 'UPI',  'Migrated from PRODONT bill #54')
)
INSERT INTO public.payments (visit_id, amount_paid, payment_mode, payment_date, notes, created_at)
SELECT
  v.id,
  ps.amount::numeric,
  ps.mode::payment_mode_type,
  ps.receipt_dt::timestamptz,
  ps.note,
  now()
FROM pay_src ps
JOIN public.patients p ON p.legacy_patient_code = ps.legacy_code
JOIN public.visits v   ON v.patient_id = p.id AND v.visit_date::date = ps.visit_dt::date
WHERE NOT EXISTS (
  SELECT 1 FROM public.payments py
  WHERE py.visit_id = v.id AND py.notes = ps.note
);

-- ─────────────────────────────────────────────────────────────
-- Verification
-- ─────────────────────────────────────────────────────────────
SELECT
  (SELECT COUNT(*) FROM public.invoices WHERE legacy_bill_number IS NOT NULL)                          AS migrated_invoices,
  (SELECT COUNT(*) FROM public.invoices WHERE legacy_bill_number IS NOT NULL AND balance_amount = 0)   AS fully_paid_invoices,
  (SELECT COUNT(*) FROM public.payments WHERE notes LIKE 'Migrated from PRODONT bill%')                AS migrated_payments,
  (SELECT SUM(amount_paid) FROM public.payments WHERE notes LIKE 'Migrated from PRODONT bill%')        AS total_collected;
