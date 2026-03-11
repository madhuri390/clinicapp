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

  /// Builds the `"components"` array for a template message.
  ///
  /// [parameters] is an ordered list of body parameter values.
  static List<Map<String, dynamic>> buildBodyComponents(
    List<String> parameters,
  ) {
    return [
      {
        'type': 'body',
        'parameters': [
          for (final p in parameters)
            {'type': 'text', 'text': p},
        ],
      },
    ];
  }

  // ── Convenience builders for each template ────────────────────────────

  /// appointment_confirmation: {{1}} patient_name, {{2}} date, {{3}} time,
  /// {{4}} doctor_name, {{5}} clinic_name
  static List<Map<String, dynamic>> confirmationParams({
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
    required String clinicName,
  }) =>
      buildBodyComponents([patientName, date, time, doctorName, clinicName]);

  /// appointment_reminder: {{1}} patient_name, {{2}} date, {{3}} time,
  /// {{4}} doctor_name
  static List<Map<String, dynamic>> reminderParams({
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
  }) =>
      buildBodyComponents([patientName, date, time, doctorName]);

  /// appointment_rescheduled: {{1}} patient_name, {{2}} old_date,
  /// {{3}} new_date, {{4}} new_time, {{5}} doctor_message
  static List<Map<String, dynamic>> rescheduleParams({
    required String patientName,
    required String oldDate,
    required String newDate,
    required String newTime,
    required String doctorMessage,
  }) =>
      buildBodyComponents(
          [patientName, oldDate, newDate, newTime, doctorMessage]);

  /// appointment_cancelled: {{1}} patient_name, {{2}} date,
  /// {{3}} doctor_message
  static List<Map<String, dynamic>> cancelParams({
    required String patientName,
    required String date,
    required String doctorMessage,
  }) =>
      buildBodyComponents([patientName, date, doctorMessage]);

  /// welcome_message: {{1}} patient_name, {{2}} clinic_name
  static List<Map<String, dynamic>> welcomeParams({
    required String patientName,
    required String clinicName,
  }) =>
      buildBodyComponents([patientName, clinicName]);

  /// treatment_update: {{1}} patient_name, {{2}} treatment_name,
  /// {{3}} status
  static List<Map<String, dynamic>> treatmentUpdateParams({
    required String patientName,
    required String treatmentName,
    required String status,
  }) =>
      buildBodyComponents([patientName, treatmentName, status]);

  /// bill_summary: {{1}} patient_name, {{2}} total, {{3}} paid,
  /// {{4}} balance
  static List<Map<String, dynamic>> billSummaryParams({
    required String patientName,
    required String total,
    required String paid,
    required String balance,
  }) =>
      buildBodyComponents([patientName, total, paid, balance]);

  /// daily_doctor_report: {{1}} doctor_name, {{2}} date,
  /// {{3}} total_count, {{4}} appointment_list
  static List<Map<String, dynamic>> dailyDoctorReportParams({
    required String doctorName,
    required String date,
    required String totalCount,
    required String appointmentList,
  }) =>
      buildBodyComponents([doctorName, date, totalCount, appointmentList]);
}
