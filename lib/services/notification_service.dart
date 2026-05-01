import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment_model.dart';
import 'appointment_store.dart';
import 'whatsapp_service.dart';

const _channelId   = 'appointment_reminders';
const _channelName = 'Appointment Reminders';
const _channelDesc = '1-hour reminders before scheduled appointments';

/// Orchestrates WhatsApp and local push notifications for appointment lifecycle events.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final WhatsAppService _whatsApp = WhatsAppService();
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _localReady = false;

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static String _fmtDate(DateTime d) => _dateFmt.format(d);

  // ── Initialization ──────────────────────────────────────────────────────

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request Android 13+ notification permission at startup.
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _localReady = true;
    debugPrint('[Notification] Local notifications initialized');
  }

  // ── Appointment lifecycle ───────────────────────────────────────────────

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
      body: '${appt.patientName} — ${appt.type} on ${_fmtDate(appt.date)} at ${Appointment.to12Hour(appt.timeSlot)}',
    );
    await scheduleAppointmentReminder(appt);
  }

  Future<void> onAppointmentRescheduled({
    required Appointment oldAppt,
    required Appointment newAppt,
    required String doctorMessage,
  }) async {
    debugPrint('[Notification] Rescheduled: ${oldAppt.id} → ${newAppt.id}');
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
      body: '${newAppt.patientName} moved to ${_fmtDate(newAppt.date)} at ${Appointment.to12Hour(newAppt.timeSlot)}',
    );
    // Replace old scheduled reminder with new one.
    await cancelAppointmentReminder(oldAppt.id);
    await scheduleAppointmentReminder(newAppt);
  }

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
    await cancelAppointmentReminder(appt.id);
  }

  /// Send appointment reminder (1 day before) — WhatsApp + push.
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
      body: 'Reminder: ${appt.patientName} has an appointment tomorrow at ${Appointment.to12Hour(appt.timeSlot)}',
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
        .map((a) => '• ${Appointment.to12Hour(a.timeSlot)} — ${a.patientName} (${a.type})')
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

  // ── Local notification scheduling ──────────────────────────────────────

  /// Schedules a local notification 1 hour before [appt.startDateTime].
  /// Safe to call on already-past appointments — silently skips.
  Future<void> scheduleAppointmentReminder(Appointment appt) async {
    if (!_localReady) return;

    final reminderTime = appt.startDateTime.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('[Notification] Reminder is in the past, skipping: ${appt.id}');
      return;
    }

    final notifId = appt.id.hashCode.abs();
    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _localNotif.zonedSchedule(
      notifId,
      'Appointment in 1 hour',
      '${appt.patientName} — ${appt.type} at ${Appointment.to12Hour(appt.timeSlot)}',
      tzReminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('[Notification] Scheduled reminder for ${appt.patientName} at $tzReminderTime (id=$notifId)');
  }

  /// Cancels the scheduled 1-hour reminder for an appointment.
  Future<void> cancelAppointmentReminder(String appointmentId) async {
    if (!_localReady) return;
    final notifId = appointmentId.hashCode.abs();
    await _localNotif.cancel(notifId);
    debugPrint('[Notification] Cancelled reminder id=$notifId for appointment $appointmentId');
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  void _sendPush({required String title, required String body}) {
    debugPrint('[Push] $title: $body');
    // TODO: Integrate with Firebase Cloud Messaging
  }
}
