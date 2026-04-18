-- ═══════════════════════════════════════════════════════════════════════════
-- Add treatment_templates table (for Add Treatment dropdown)
-- Run in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists public.treatment_templates (
  id               uuid primary key default uuid_generate_v4(),
  name             text          not null,
  description      text,
  default_cost     numeric(10,2) not null default 0,
  default_sittings int           not null default 1,
  is_active        boolean       not null default true,
  created_at       timestamptz   not null default now()
);

alter table public.treatment_templates enable row level security;
drop policy if exists "staff_all" on public.treatment_templates;
create policy "staff_all" on public.treatment_templates
  for all to authenticated using (true) with check (true);

-- Patients can read templates when booking
drop policy if exists "patient_read" on public.treatment_templates;
create policy "patient_read" on public.treatment_templates
  for select to authenticated using (true);

-- ── Seed common dental treatments ──────────────────────────────────────────
insert into public.treatment_templates (name, description, default_cost, default_sittings) values
  ('Root Canal Treatment',       'Endodontic therapy to remove infected pulp and seal the canal.',         3500, 3),
  ('Crown Placement',            'Ceramic or metal crown fitted over a damaged tooth.',                    5000, 2),
  ('Teeth Whitening',            'In-office whitening session with custom shade matching.',                 1500, 1),
  ('Scaling & Polishing',        'Professional cleaning to remove tartar and staining.',                    800, 1),
  ('Tooth Extraction',           'Removal of a decayed or impacted tooth under local anaesthesia.',        1200, 1),
  ('Dental Implant',             'Titanium implant to replace a missing tooth.',                          25000, 4),
  ('Orthodontic Braces',         'Metal/ceramic braces to correct tooth alignment over 12–18 months.',   35000, 12),
  ('Clear Aligner Therapy',      'Invisible aligners to correct mild-moderate crowding.',                 22000, 8),
  ('Composite Filling',          'Tooth-coloured resin filling for cavities.',                             1200, 1),
  ('Gum Treatment (Flap)',       'Periodontal flap surgery to treat deep gum disease.',                   6000, 2),
  ('Fluoride Application',       'Topical fluoride varnish to strengthen enamel.',                         500, 1),
  ('Wisdom Tooth Extraction',    'Surgical removal of impacted wisdom tooth.',                            2500, 1),
  ('Dentures (Complete)',        'Full set of removable artificial teeth.',                               12000, 3),
  ('Veneer Placement',           'Thin porcelain shell bonded to front of tooth for aesthetics.',         6000, 2),
  ('Night Guard Fabrication',    'Custom acrylic guard to prevent bruxism (teeth grinding).',             2000, 2)
on conflict do nothing;
