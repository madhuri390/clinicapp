import '../models/patient_model.dart';
import 'auth_service.dart';

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

  /// Name for headers: auth profile first, then linked patient display name.
  static String resolvedPortalDisplayName() {
    final u = AuthService.currentUser;
    if (u != null) {
      final meta = u.userMetadata;
      final fn = meta?['full_name'] as String? ?? meta?['name'] as String?;
      if (fn != null && fn.trim().isNotEmpty) return fn.trim();
      final em = u.email;
      if (em != null && em.isNotEmpty) {
        final at = em.indexOf('@');
        if (at > 0) return em.substring(0, at);
      }
    }
    final n = portalPatientName;
    if (n != null && n.trim().isNotEmpty) return n.trim();
    return 'there';
  }
}
