import '../models/patient_model.dart';

/// Linked patient record for the patient portal (set when shell initializes).
class PatientSession {
  PatientSession._();

  static Patient? linked;
  static String? portalPatientId;
  static String? portalPatientName;

  static void setPortal({
    required String patientId,
    required String displayName,
    Patient? patient,
  }) {
    portalPatientId = patientId;
    portalPatientName = displayName;
    linked = patient;
  }

  static void clear() {
    linked = null;
    portalPatientId = null;
    portalPatientName = null;
  }
}
