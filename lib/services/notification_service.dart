import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import 'appointment_store.dart';
import 'whatsapp_service.dart';

/// Orchestrates WhatsApp and push notifications for appointment lifecycle events.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final WhatsAppService _whatsApp = WhatsAppService();

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static String _fmtDate(DateTime d) => _dateFmt.format(d);

  // ── Appointment lifecycle ──────────────────────────────────────────────

  /// Called when a new appointment is created.
  Future<void> onAppointmentCreated(Appointment appt) async {
    debugPrint('[Notification] Appointment created: ${appt.id}');
    await _whatsApp.sendAppointmentConfirmation(
      phone: appt.patientPhone,
      patientName: appt.patientName,
      date: _fmtDate(appt.date),
      time: appt.timeRange,
      doctorName: appt.doctorName,
    );
    _sendPush(
      title: 'Appointment Confirmed',
      body:
          '${appt.patientName} — ${appt.type} on ${_fmtDate(appt.date)} at ${Appointment.to12Hour(appt.timeSlot)}',
    );
  }

  /// Called when an appointment is rescheduled.
  Future<void> onAppointmentRescheduled({
    required Appointment oldAppt,
    required Appointment newAppt,
    required String doctorMessage,
  }) async {
    debugPrint(
      '[Notification] Rescheduled: ${oldAppt.id} → ${newAppt.id}',
    );
    await _whatsApp.sendRescheduleNotification(
      phone: newAppt.patientPhone,
      patientName: newAppt.patientName,
      oldDate: _fmtDate(oldAppt.date),
      newDate: _fmtDate(newAppt.date),
      newTime: newAppt.timeRange,
      doctorMessage: doctorMessage,
    );
    _sendPush(
      title: 'Appointment Rescheduled',
      body:
          '${newAppt.patientName} moved to ${_fmtDate(newAppt.date)} at ${Appointment.to12Hour(newAppt.timeSlot)}',
    );
  }

  /// Called when an appointment is cancelled.
  Future<void> onAppointmentCancelled({
    required Appointment appt,
    required String doctorMessage,
  }) async {
    debugPrint('[Notification] Cancelled: ${appt.id}');
    await _whatsApp.sendCancellationNotification(
      phone: appt.patientPhone,
      patientName: appt.patientName,
      date: _fmtDate(appt.date),
      doctorMessage: doctorMessage,
    );
    _sendPush(
      title: 'Appointment Cancelled',
      body: '${appt.patientName} — ${appt.type} on ${_fmtDate(appt.date)}',
    );
  }

  /// Send appointment reminder (1 day before).
  Future<void> sendReminder(Appointment appt) async {
    debugPrint('[Notification] Reminder: ${appt.id}');
    await _whatsApp.sendAppointmentReminder(
      phone: appt.patientPhone,
      patientName: appt.patientName,
      date: _fmtDate(appt.date),
      time: appt.timeRange,
      doctorName: appt.doctorName,
    );
    _sendPush(
      title: 'Appointment Reminder',
      body:
          'Reminder: ${appt.patientName} has an appointment tomorrow at ${Appointment.to12Hour(appt.timeSlot)}',
    );
  }

  /// Send daily report to doctor — both WhatsApp and push.
  Future<void> sendDailyReport({
    required String doctorPhone,
    required String doctorName,
    required DateTime date,
  }) async {
    final store = AppointmentStore.instance;
    final dayAppts = store.getAppointmentsForDate(date).where(
          (a) =>
              a.status != AppointmentStatus.cancelled &&
              a.status != AppointmentStatus.rescheduled,
        ).toList();

    if (dayAppts.isEmpty) {
      debugPrint('[Notification] No appointments for ${_fmtDate(date)}');
      return;
    }

    final summaries = dayAppts
        .map(
          (a) =>
              '• ${Appointment.to12Hour(a.timeSlot)} — ${a.patientName} (${a.type})',
        )
        .toList();

    await _whatsApp.sendDailyDoctorReport(
      doctorPhone: doctorPhone,
      doctorName: doctorName,
      date: _fmtDate(date),
      totalAppointments: dayAppts.length,
      appointmentSummaries: summaries,
    );

    _sendPush(
      title: 'Today\'s Schedule',
      body: '${dayAppts.length} appointments today. Tap to view.',
    );
  }

  // ── Push notification placeholder ─────────────────────────────────────

  /// Placeholder for push notification (FCM).
  /// Replace with Firebase Cloud Messaging implementation.
  void _sendPush({required String title, required String body}) {
    debugPrint('[Push] $title: $body');
    // TODO: Integrate with Firebase Cloud Messaging
    // FirebaseMessaging.instance.sendMessage(...)
  }
}
