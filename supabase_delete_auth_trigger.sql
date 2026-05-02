-- This script adds triggers to automatically delete the associated Supabase Auth user
-- when a patient or doctor (staff) record is deleted from the public schema.

-- 1. Create a function to handle the auth user deletion.
-- Use SECURITY DEFINER to bypass RLS and allow deletion from the auth.users table.
CREATE OR REPLACE FUNCTION public.handle_auth_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- If the record being deleted has an associated auth_user_id, delete it from auth.users
  IF OLD.auth_user_id IS NOT NULL THEN
    DELETE FROM auth.users WHERE id = OLD.auth_user_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Add trigger to patients table
DROP TRIGGER IF EXISTS on_patient_deleted ON public.patients;
CREATE TRIGGER on_patient_deleted
BEFORE DELETE ON public.patients
FOR EACH ROW
EXECUTE FUNCTION public.handle_auth_user_deletion();

-- 3. Add trigger to doctors table
DROP TRIGGER IF EXISTS on_doctor_deleted ON public.doctors;
CREATE TRIGGER on_doctor_deleted
BEFORE DELETE ON public.doctors
FOR EACH ROW
EXECUTE FUNCTION public.handle_auth_user_deletion();
