import '../models/appointment_model.dart';

/// In-memory NoSQL-style appointment store (singleton).
///
/// Mirrors the existing [LocalStore] pattern used by the app.
class AppointmentStore {
  AppointmentStore._();
  static final instance = AppointmentStore._();

  final List<Appointment> _appointments = [];

  // ── Queries ─────────────────────────────────────────────────────────────

  List<Appointment> get all => List.unmodifiable(_appointments);

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList()
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
  }

  List<Appointment> getAppointmentsForPatient(String patientId) {
    return _appointments
        .where((a) => a.patientId == patientId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> getAppointmentsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return _appointments
        .where((a) => a.date.isAfter(startDay) && a.date.isBefore(endDay))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns time slots already booked for a given date.
  List<String> getBookedSlotsForDate(DateTime date) {
    final dayAppts = getAppointmentsForDate(date).where(
      (a) =>
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.rescheduled,
    );
    final bookedSlots = <String>[];
    for (final a in dayAppts) {
      // Mark all 30-min blocks the appointment occupies.
      final parts = a.timeSlot.split(':');
      var h = int.parse(parts[0]);
      var m = int.parse(parts[1]);
      var remaining = a.duration;
      while (remaining > 0) {
        bookedSlots.add(
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
        );
        m += 30;
        if (m >= 60) {
          h += 1;
          m -= 60;
        }
        remaining -= 30;
      }
    }
    return bookedSlots;
  }

  // ── Mutations ───────────────────────────────────────────────────────────

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  void rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newTimeSlot,
    required String doctorMessage,
  }) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx < 0) return;

    final old = _appointments[idx];

    // Mark old as rescheduled with doctor's message.
    _appointments[idx] = old.copyWith(
      status: AppointmentStatus.rescheduled,
      doctorMessage: doctorMessage,
    );

    // Create the new appointment.
    final newAppt = old.copyWith(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      date: newDate,
      timeSlot: newTimeSlot,
      status: AppointmentStatus.scheduled,
      doctorMessage: null,
      updatedAt: DateTime.now(),
    );
    _appointments.add(newAppt);
  }

  void cancelAppointment({
    required String id,
    required String doctorMessage,
  }) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    _appointments[idx] = _appointments[idx].copyWith(
      status: AppointmentStatus.cancelled,
      doctorMessage: doctorMessage,
    );
  }

  void completeAppointment(String id) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    _appointments[idx] = _appointments[idx].copyWith(
      status: AppointmentStatus.completed,
    );
  }

  void startAppointment(String id) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    _appointments[idx] = _appointments[idx].copyWith(
      status: AppointmentStatus.ongoing,
    );
  }

  /// Auto-generate a series of appointments from a treatment plan.
  ///
  /// [sittingCount] — number of sittings to schedule
  /// [frequencyDays] — gap between sittings in days (e.g. 7 = weekly)
  /// [startDate] — first appointment date
  /// [preferredTimeSlot] — time slot for all generated appointments
  List<Appointment> generateAppointmentsFromTreatmentPlan({
    required String treatmentPlanId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String treatmentType,
    required String doctorName,
    required int sittingCount,
    required int frequencyDays,
    required DateTime startDate,
    required String preferredTimeSlot,
    int duration = 30,
  }) {
    final generated = <Appointment>[];
    for (var i = 0; i < sittingCount; i++) {
      final apptDate = startDate.add(Duration(days: i * frequencyDays));
      final appt = Appointment(
        id: 'appt_tp_${treatmentPlanId}_$i',
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        date: apptDate,
        timeSlot: preferredTimeSlot,
        duration: duration,
        type: '$treatmentType - Sitting ${i + 1}',
        doctorName: doctorName,
        treatmentPlanId: treatmentPlanId,
        notes: 'Auto-scheduled from treatment plan (Sitting ${i + 1} of $sittingCount)',
      );
      _appointments.add(appt);
      generated.add(appt);
    }
    return generated;
  }

  // ── Seed ────────────────────────────────────────────────────────────────

  bool _seeded = false;

  void seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Today's appointments
    _appointments.addAll([
      Appointment(
        id: 'appt_1',
        patientId: 'p1',
        patientName: 'Sarah Johnson',
        patientPhone: '+919876543210',
        date: today,
        timeSlot: '09:00',
        duration: 60,
        type: 'Root Canal - Follow-up',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: 'appt_2',
        patientId: 'p2',
        patientName: 'Michael Chen',
        patientPhone: '+919876543211',
        date: today,
        timeSlot: '10:30',
        duration: 30,
        type: 'Crown Placement',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.ongoing,
      ),
      Appointment(
        id: 'appt_3',
        patientId: 'p3',
        patientName: 'Emma Williams',
        patientPhone: '+919876543212',
        date: today,
        timeSlot: '11:30',
        duration: 60,
        type: 'Wisdom Tooth Extraction',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'appt_4',
        patientId: 'p4',
        patientName: 'John Davis',
        patientPhone: '+919876543213',
        date: today,
        timeSlot: '14:00',
        duration: 30,
        type: 'Teeth Cleaning',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'appt_5',
        patientId: 'p5',
        patientName: 'Lisa Anderson',
        patientPhone: '+919876543214',
        date: today,
        timeSlot: '15:00',
        duration: 60,
        type: 'Dental Checkup & Cleaning',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
      ),
    ]);

    // Tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    _appointments.addAll([
      Appointment(
        id: 'appt_6',
        patientId: 'p1',
        patientName: 'Sarah Johnson',
        patientPhone: '+919876543210',
        date: tomorrow,
        timeSlot: '10:00',
        duration: 30,
        type: 'Root Canal - Final Check',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'appt_7',
        patientId: 'p6',
        patientName: 'Robert Brown',
        patientPhone: '+919876543215',
        date: tomorrow,
        timeSlot: '11:00',
        duration: 60,
        type: 'Cavity Filling',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
      ),
    ]);

    // Yesterday — some completed + one cancelled
    final yesterday = today.subtract(const Duration(days: 1));
    _appointments.addAll([
      Appointment(
        id: 'appt_8',
        patientId: 'p3',
        patientName: 'Emma Williams',
        patientPhone: '+919876543212',
        date: yesterday,
        timeSlot: '09:30',
        duration: 30,
        type: 'X-Ray Consultation',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: 'appt_9',
        patientId: 'p4',
        patientName: 'John Davis',
        patientPhone: '+919876543213',
        date: yesterday,
        timeSlot: '14:00',
        duration: 30,
        type: 'Teeth Whitening',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.cancelled,
        doctorMessage: 'Patient requested cancellation due to personal reasons.',
      ),
    ]);

    // Day after tomorrow
    final dayAfter = today.add(const Duration(days: 2));
    _appointments.addAll([
      Appointment(
        id: 'appt_10',
        patientId: 'p2',
        patientName: 'Michael Chen',
        patientPhone: '+919876543211',
        date: dayAfter,
        timeSlot: '09:00',
        duration: 60,
        type: 'Crown Adjustment',
        doctorName: 'Dr. Amanda Foster',
        status: AppointmentStatus.scheduled,
        treatmentPlanId: 'seed_t1',
        notes: 'Auto-scheduled from treatment plan',
      ),
    ]);
  }
}
