import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment_model.dart';
import 'app_role_service.dart';
import 'appointment_store.dart';
import 'whatsapp_service.dart';

const _channelId   = 'appointment_reminders';
const _channelName = 'Appointment Reminders';
const _channelDesc = 'Reminders before scheduled appointments';

/// Orchestrates WhatsApp and local push notifications for appointment lifecycle events.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final WhatsAppService _whatsApp = WhatsAppService();
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _localReady = false;

  /// Whether the device supports exact alarm scheduling.
  /// If false, reminders may be delayed by a few minutes.
  bool _exactAlarmsPermitted = false;
  bool get exactAlarmsPermitted => _exactAlarmsPermitted;

  /// True if the user has already been prompted about exact alarms this session.
  bool _alarmDialogShown = false;
  bool get alarmDialogShown => _alarmDialogShown;
  void markAlarmDialogShown() => _alarmDialogShown = true;

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static String _fmtDate(DateTime d) => _dateFmt.format(d);

  // ── Initialization ──────────────────────────────────────────────────────

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request Android 13+ notification permission at startup.
    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // Check if exact alarms are permitted.
    _exactAlarmsPermitted =
        await androidPlugin?.canScheduleExactNotifications() ?? true;

    _localReady = true;
    debugPrint('[Notification] Local notifications initialized '
        '(exactAlarms=$_exactAlarmsPermitted)');
  }

  /// Opens the system Settings page for exact alarm permission.
  /// Call after showing an in-app explanation dialog.
  Future<void> openExactAlarmSettings() async {
    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// Re-checks exact alarm permission (call after returning from Settings).
  Future<void> recheckExactAlarmPermission() async {
    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    _exactAlarmsPermitted =
        await androidPlugin?.canScheduleExactNotifications() ?? true;
    debugPrint('[Notification] Exact alarms rechecked: $_exactAlarmsPermitted');
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
    await scheduleAppointmentReminders(appt);
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
    // Replace old scheduled reminders with new ones.
    await cancelAppointmentReminders(oldAppt.id);
    await scheduleAppointmentReminders(newAppt);
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
    await cancelAppointmentReminders(appt.id);
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

  // ── 3-tier local notification scheduling ───────────────────────────────

  /// Schedule reminders for all upcoming appointments in one go.
  /// Call after loading appointments from the server (e.g. on fresh install/login).
  Future<void> scheduleRemindersForAll(List<Appointment> appointments) async {
    final upcoming = appointments.where((a) =>
        a.status == AppointmentStatus.scheduled ||
        a.status == AppointmentStatus.ongoing,
    ).toList();

    debugPrint('[Notification] Bulk-scheduling reminders for ${upcoming.length} upcoming appointments');
    for (final appt in upcoming) {
      await scheduleAppointmentReminders(appt);
    }
  }

  /// Deterministic notification IDs for the 3 reminder tiers.
  /// Using `* 3 + offset` ensures each tier gets a unique, stable ID.
  /// Mod by 715827881 so the max value (715827881*3+2 = 2147483645) fits in 32-bit.
  static int _baseId(String apptId) => apptId.hashCode.abs() % 715827881;
  static int _prevNightId(String apptId)  => _baseId(apptId) * 3;
  static int _oneHourId(String apptId)    => _baseId(apptId) * 3 + 1;
  static int _fifteenMinId(String apptId) => _baseId(apptId) * 3 + 2;

  /// Role-aware notification body — doctors see patient names,
  /// patients see doctor + procedure names.
  static String _bodyForRole(Appointment appt, {String? suffix}) {
    final time12 = Appointment.to12Hour(appt.timeSlot);
    final extra = suffix != null ? ' $suffix' : '';
    if (AppRoleService.isPatient) {
      return '${appt.type} with ${appt.doctorName} at $time12$extra';
    }
    return '${appt.patientName} — ${appt.type} at $time12$extra';
  }

  /// Schedules **3 local notifications** for an appointment:
  ///   1. Previous day at 10:00 PM
  ///   2. 1 hour before
  ///   3. 15 minutes before
  ///
  /// Safe to call on already-past appointments — each tier is individually
  /// checked and silently skipped if its fire time is in the past.
  Future<void> scheduleAppointmentReminders(Appointment appt) async {
    if (!_localReady) return;

    final now = DateTime.now();
    final startDT = appt.startDateTime;

    // ── Tier 1: Previous day at 10:00 PM ──
    final prevNight = DateTime(
      appt.date.year, appt.date.month, appt.date.day - 1, 22, 0,
    );
    if (prevNight.isAfter(now)) {
      await _scheduleOne(
        id: _prevNightId(appt.id),
        time: prevNight,
        title: 'Appointment Tomorrow',
        body: _bodyForRole(appt, suffix: 'tomorrow'),
      );
    } else {
      debugPrint('[Notification] Prev-night reminder in the past, skipping: ${appt.id}');
    }

    // ── Tier 2: 1 hour before ──
    final oneHourBefore = startDT.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await _scheduleOne(
        id: _oneHourId(appt.id),
        time: oneHourBefore,
        title: 'Appointment in 1 Hour',
        body: _bodyForRole(appt),
      );
    } else {
      debugPrint('[Notification] 1-hour reminder in the past, skipping: ${appt.id}');
    }

    // ── Tier 3: 15 minutes before ──
    final fifteenMinBefore = startDT.subtract(const Duration(minutes: 15));
    if (fifteenMinBefore.isAfter(now)) {
      await _scheduleOne(
        id: _fifteenMinId(appt.id),
        time: fifteenMinBefore,
        title: 'Appointment in 15 Minutes',
        body: _bodyForRole(appt, suffix: '— starting soon'),
      );
    } else {
      debugPrint('[Notification] 15-min reminder in the past, skipping: ${appt.id}');
    }
  }

  /// Cancels all 3 scheduled reminders for an appointment.
  Future<void> cancelAppointmentReminders(String appointmentId) async {
    if (!_localReady) return;
    await _localNotif.cancel(_prevNightId(appointmentId));
    await _localNotif.cancel(_oneHourId(appointmentId));
    await _localNotif.cancel(_fifteenMinId(appointmentId));
    debugPrint('[Notification] Cancelled all 3 reminders for appointment $appointmentId');
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  /// Schedules a single local notification at the given [time].
  /// Tries exact alarms first; falls back to inexact if permission is denied.
  Future<void> _scheduleOne({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);
    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      // Try exact alarm first (precise timing).
      await _localNotif.zonedSchedule(
        id, title, body, tzTime, notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[Notification] Scheduled (exact) "$title" at $tzTime (id=$id)');
    } catch (_) {
      // Fallback to inexact — may be off by a few minutes but always works.
      try {
        await _localNotif.zonedSchedule(
          id, title, body, tzTime, notifDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('[Notification] Scheduled (inexact fallback) "$title" at $tzTime (id=$id)');
      } catch (e) {
        debugPrint('[Notification] Failed to schedule "$title" (id=$id): $e');
      }
    }
  }

  void _sendPush({required String title, required String body}) {
    debugPrint('[Push] $title: $body');
    // TODO: Integrate with Firebase Cloud Messaging
  }
}
