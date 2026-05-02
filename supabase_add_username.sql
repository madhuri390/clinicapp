-- Add username column to patients
ALTER TABLE public.patients
ADD COLUMN username text UNIQUE;

-- Add username column to doctors
ALTER TABLE public.doctors
ADD COLUMN username text UNIQUE;
