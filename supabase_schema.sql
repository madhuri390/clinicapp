-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.appointments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  patient_id uuid NOT NULL,
  doctor_id uuid,
  treatment_plan_id uuid,
  patient_name text NOT NULL,
  patient_phone text NOT NULL,
  doctor_name text NOT NULL,
  date date NOT NULL,
  time_slot text NOT NULL,
  duration smallint NOT NULL DEFAULT 30 CHECK (duration > 0),
  type text NOT NULL,
  notes text,
  status USER-DEFINED NOT NULL DEFAULT 'scheduled'::appointment_status,
  doctor_message text,
  reminder_sent_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT appointments_pkey PRIMARY KEY (id),
  CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id),
  CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id),
  CONSTRAINT appointments_treatment_plan_id_fkey FOREIGN KEY (treatment_plan_id) REFERENCES public.treatment_plans(id)
);
CREATE TABLE public.doctors (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  first_name text NOT NULL,
  last_name text,
  email text UNIQUE,
  phone text,
  specialisation USER-DEFINED NOT NULL DEFAULT 'General Dentist'::doctor_specialisation,
  qualification text,
  registration_no text UNIQUE,
  experience_yrs smallint CHECK (experience_yrs >= 0),
  is_active boolean NOT NULL DEFAULT true,
  consulting_fee numeric NOT NULL DEFAULT 0,
  auth_user_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  clinic_name text,
  location text,
  work_start_time time without time zone,
  work_end_time time without time zone,
  CONSTRAINT doctors_pkey PRIMARY KEY (id),
  CONSTRAINT doctors_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.file_attachments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  visit_id uuid,
  treatment_plan_id uuid,
  file_name text NOT NULL,
  file_type text NOT NULL DEFAULT 'Other'::text,
  file_url text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT file_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT file_attachments_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id),
  CONSTRAINT file_attachments_treatment_plan_id_fkey FOREIGN KEY (treatment_plan_id) REFERENCES public.treatment_plans(id)
);
CREATE TABLE public.inventory (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  category text,
  quantity integer NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  unit text NOT NULL DEFAULT 'units'::text,
  min_stock integer NOT NULL DEFAULT 0,
  unit_cost numeric NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT inventory_pkey PRIMARY KEY (id)
);
CREATE TABLE public.invoices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  patient_id uuid,
  visit_id uuid,
  total_amount numeric,
  amount_paid numeric,
  balance_amount numeric,
  invoice_date timestamp without time zone DEFAULT now(),
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT invoices_pkey PRIMARY KEY (id)
);
CREATE TABLE public.patients (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  first_name text NOT NULL,
  last_name text,
  phone text NOT NULL,
  email text,
  gender USER-DEFINED,
  date_of_birth date,
  blood_group USER-DEFINED,
  address text,
  medical_history text,
  dental_history text,
  auth_user_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT patients_pkey PRIMARY KEY (id),
  CONSTRAINT patients_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  visit_id uuid NOT NULL,
  treatment_plan_id uuid,
  sitting_id uuid,
  prescription_id uuid,
  file_id uuid,
  amount_paid numeric NOT NULL CHECK (amount_paid >= 0::numeric),
  payment_mode USER-DEFINED NOT NULL DEFAULT 'Cash'::payment_mode_type,
  payment_date timestamp with time zone NOT NULL DEFAULT now(),
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id),
  CONSTRAINT payments_treatment_plan_id_fkey FOREIGN KEY (treatment_plan_id) REFERENCES public.treatment_plans(id),
  CONSTRAINT payments_sitting_id_fkey FOREIGN KEY (sitting_id) REFERENCES public.sittings(id),
  CONSTRAINT payments_prescription_id_fkey FOREIGN KEY (prescription_id) REFERENCES public.prescriptions(id),
  CONSTRAINT payments_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.file_attachments(id)
);
CREATE TABLE public.prescriptions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  visit_id uuid,
  treatment_plan_id uuid,
  sitting_id uuid,
  medicine_name text NOT NULL,
  dosage text,
  duration text,
  instructions text,
  price numeric NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT prescriptions_pkey PRIMARY KEY (id),
  CONSTRAINT prescriptions_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id),
  CONSTRAINT prescriptions_treatment_plan_id_fkey FOREIGN KEY (treatment_plan_id) REFERENCES public.treatment_plans(id),
  CONSTRAINT prescriptions_sitting_id_fkey FOREIGN KEY (sitting_id) REFERENCES public.sittings(id)
);
CREATE TABLE public.sittings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  visit_id uuid NOT NULL,
  treatment_plan_id uuid NOT NULL,
  sitting_date timestamp with time zone NOT NULL,
  duration_str text NOT NULL DEFAULT '30 min'::text,
  notes text,
  cost numeric NOT NULL DEFAULT 0,
  status USER-DEFINED NOT NULL DEFAULT 'Scheduled'::sitting_status,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT sittings_pkey PRIMARY KEY (id),
  CONSTRAINT sittings_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id),
  CONSTRAINT sittings_treatment_plan_id_fkey FOREIGN KEY (treatment_plan_id) REFERENCES public.treatment_plans(id)
);
CREATE TABLE public.treatment_plans (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  visit_id uuid NOT NULL,
  treatment_name text NOT NULL,
  description text,
  total_cost numeric NOT NULL DEFAULT 0,
  status USER-DEFINED NOT NULL DEFAULT 'planned'::treatment_status,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT treatment_plans_pkey PRIMARY KEY (id),
  CONSTRAINT treatment_plans_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id)
);
CREATE TABLE public.visits (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  patient_id uuid NOT NULL,
  doctor_id uuid,
  visit_date timestamp with time zone NOT NULL DEFAULT now(),
  chief_complaint text,
  diagnosis text,
  notes text,
  next_visit_date date,
  status USER-DEFINED NOT NULL DEFAULT 'ongoing'::visit_status,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT visits_pkey PRIMARY KEY (id),
  CONSTRAINT visits_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id),
  CONSTRAINT visits_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id)
);