/// Defines all WhatsApp Business API message template names and their
/// parameter structures.  Submit these to Meta Business Manager for approval.
class WhatsAppTemplates {
  WhatsAppTemplates._();

  // ── Template names (must match exactly what you submit to Meta) ────────

  static const appointmentConfirmation = 'appointment_confirmation';
  static const appointmentReminder = 'appointment_reminder';
  static const appointmentRescheduled = 'appointment_rescheduled';
  static const appointmentCancelled = 'appointment_cancelled';
  static const welcomeMessage = 'welcome_message';
  static const treatmentUpdate = 'treatment_update';
  static const billSummary = 'bill_summary';
  static const dailyDoctorReport = 'daily_doctor_report';

  // ── Helper: build the components array for Meta API ────────────────────

  /// Builds the `"components"` array for a template message using named parameters.
  ///
  /// [parameters] is a map of parameter names to string values.
  static List<Map<String, dynamic>> buildBodyComponents(
    Map<String, String> parameters,
  ) {
    return [
      {
        'type': 'body',
        'parameters': [
          for (final entry in parameters.entries)
            {
              'type': 'text',
              'parameter_name': entry.key,
              'text': entry.value,
            },
        ],
      },
    ];
  }

  // ── Convenience builders for each template ────────────────────────────

  static List<Map<String, dynamic>> confirmationParams({
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
    required String clinicName,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'date': date,
        'time': time,
        'doctor_name': doctorName,
        'clinic_name': clinicName,
      });

  static List<Map<String, dynamic>> reminderParams({
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'date': date,
        'time': time,
        'doctor_name': doctorName,
      });

  static List<Map<String, dynamic>> rescheduleParams({
    required String patientName,
    required String oldDate,
    required String newDate,
    required String newTime,
    required String doctorMessage,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'old_date': oldDate,
        'new_date': newDate,
        'new_time': newTime,
        'doctor_message': doctorMessage,
      });

  static List<Map<String, dynamic>> cancelParams({
    required String patientName,
    required String date,
    required String doctorMessage,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'date': date,
        'doctor_message': doctorMessage,
      });

  static List<Map<String, dynamic>> welcomeParams({
    required String patientName,
    required String clinicName,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'clinic_name': clinicName,
      });

  static List<Map<String, dynamic>> treatmentUpdateParams({
    required String patientName,
    required String treatmentName,
    required String status,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'treatment_name': treatmentName,
        'status': status,
      });

  static List<Map<String, dynamic>> billSummaryParams({
    required String patientName,
    required String total,
    required String paid,
    required String balance,
  }) =>
      buildBodyComponents({
        'patient_name': patientName,
        'total': total,
        'paid': paid,
        'balance': balance,
      });

  static List<Map<String, dynamic>> dailyDoctorReportParams({
    required String doctorName,
    required String date,
    required String totalCount,
    required String appointmentList,
  }) =>
      buildBodyComponents({
        'doctor_name': doctorName,
        'date': date,
        'total_count': totalCount,
        'appointment_list': appointmentList,
      });
}
