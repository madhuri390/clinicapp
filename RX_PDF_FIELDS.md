# Rx PDF – Data Mapping (DB → PDF)

This document explains **exactly which values are picked** when generating the **Rx PDF** via:

- `PdfGeneratorService.generatePrescriptionPdfForVisit(visitId: ...)`

File: `lib/services/pdf_generator_service.dart`

---

## Header (Doctor + Clinic letterhead)

- **Logo**
  - Source: asset `assets/images/prodontics_logo.png`

- **Doctor name (left column title)**
  - Source: `doctors.first_name`, `doctors.last_name` (by `visits.doctor_id`)
  - Fallback: `VisitDetail.doctorName`
  - Final formatting: uppercased and prefixed with `Dr.` (e.g. `DR. SURYA TEJA. S`)

- **Qualification lines (left column body)**
  - Source: `doctors.qualification`
  - Fallback text (reference design):
    - `DENTAL SURGEON & IMPLANTOLOGIST,`
    - `REGN NO : A16733.`
    - `BACHELOR OF DENTAL SURGERY,`
    - `MASTERSHIP IN ORAL IMPLANTOLOGY.`

- **Registration number**
  - Source: `doctors.registration_no`
  - Fallback: `A16733`
  - Rendered as: `REGN NO : <registration_no>.`

- **Clinic title (right column heading)**
  - Source: `doctors.clinic_name` (uppercased)
  - Fallback: `PRODONTICS DENTAL SPECIALITIES`

- **Clinic address**
  - Source: `doctors.location`
  - Fallback: the reference address block used in the PDF generator

- **Clinic phone**
  - Source: `doctors.phone`
  - Fallback: `9490556555`

---

## Patient info bar

- **Patient name**
  - Source: `patients.first_name`, `patients.last_name`
  - Rendered: **bold italic** for the name itself

- **Gender**
  - Source: `patients.gender`
  - Fallback: `—`

- **Age**
  - Source: calculated from `patients.date_of_birth` (years)
  - Fallback: `—`

- **Phone**
  - Source: `patients.phone`

- **Date of generation**
  - Source: `DateTime.now()` at PDF generation time
  - Rendered as: `dd/MM/yyyy, HH:mm`

---

## Body sections

### 1) DENTAL PROCEDURES table

Rows come from **treatment plans for the visit**:

- Source table: `treatment_plans` filtered by `visit_id`
- **Procedure name column**
  - Source: `treatment_plans.treatment_name`
  - Fallback: `Procedure`

- **Teeth column**
  - Source: extracted tooth numbers from text using FDI pattern **11–48**
  - Text searched:
    - `treatment_plans.treatment_name`
    - `treatment_plans.description`
    - All related sitting notes for that treatment: `sittings.notes` (where `sittings.treatment_plan_id == treatment_plans.id`)
  - If nothing found: `—`

### 2) EXAMINATION FINDINGS

- Source: `visits.chief_complaint`
- Fallback: `visits.notes`
- Fallback: `—`

### 3) DIAGNOSIS

- Source: `visits.diagnosis`
- Fallback: `—`

### 4) TREATMENTS PRESCRIBED (bullet list)

- Source: one bullet per treatment plan:
  - `treatment_plans.treatment_name  -   treatment_plans.description`
- If `description` is empty: shows only `treatment_name`
- If both empty: omitted
- If no items: `—`

### 5) TREATMENTS DONE (bullet list)

- Source: `sittings` where `sittings.status == 'Completed'`
- Value shown: `sittings.notes`
- If no items: `—`

### 6) PRESCRIPTION table

Rows come from `prescriptions` for the visit:

- Source table: `prescriptions` filtered by `visit_id`
- **Medications column**
  - Source: `prescriptions.medicine_name`
  - If it contains newlines, first line is styled bold, remaining lines regular
- **Dose column**
  - Source: `prescriptions.dosage`
  - Fallback: `—`
- **Frequency column**
  - Source: `prescriptions.instructions`
  - Fallback: `—`
  - Newlines are preserved (e.g. `1-0-1\nAfter Meal`)
- **Duration column** ✅
  - Source: `prescriptions.duration`
  - Fallback: `—`

### 7) FOLLOWUP

- Preferred source: `visits.next_visit_date`
- Fallback: next scheduled appointment for the same patient:
  - `appointments.patient_id == visits.patient_id`
  - `appointments.status == 'scheduled'`
  - appointment date strictly after the visit date
- If none: `—`

### 8) INVESTIGATIONS (bullet list)

- Source table: `file_attachments` filtered by `visit_id`
- Bullet format:
  - Bold: `file_attachments.file_name`
  - Normal: ` -   file_attachments.file_type` (if present)

---

## Footer (signature)

- **Signature image**
  - Current implementation: **placeholder text signature** rendered using a cursive font.
  - If you provide a real signature image asset path, we can replace this.

- **Doctor name under signature**
  - Source: same as header doctor name

