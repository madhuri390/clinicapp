import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment_model.dart';

class AppointmentRepository {
  AppointmentRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Appointment> book(Appointment appointment) async {
    if (!appointment.startDateTime.isAfter(DateTime.now())) {
      throw Exception('Cannot book an appointment in the past');
    }
    // DB generates UUID; client string ids (e.g. appt_…) are invalid for uuid columns.
    final row = Map<String, dynamic>.from(appointment.toJson())
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');
    final data = await _client.from('appointments').insert(row).select().single();
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> getForDoctor(String doctorId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('doctor_id', doctorId)
        .order('date', ascending: true)
        .order('time_slot', ascending: true);
    return (data as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Appointment>> getForPatient(String patientId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('patient_id', patientId)
        .order('date', ascending: true)
        .order('time_slot', ascending: true);
    return (data as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelAsPatient({
    required Appointment appointment,
  }) async {
    _enforceOneHourRule(appointment);
    await _client
        .from('appointments')
        .update({'status': AppointmentStatus.cancelled.name})
        .eq('id', appointment.id);
  }

  Future<void> rescheduleAsPatient({
    required Appointment appointment,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    _enforceOneHourRule(appointment);
    await _client.from('appointments').update({
      'date': Appointment.sqlDateOnly(newDate),
      'time_slot': newTimeSlot,
      'status': AppointmentStatus.rescheduled.name,
    }).eq('id', appointment.id);
  }

  Future<void> cancelAsDoctor({
    required Appointment appointment,
    String? doctorMessage,
  }) async {
    _enforceOneHourRule(appointment);
    await _client.from('appointments').update({
      'status': AppointmentStatus.cancelled.name,
      if (doctorMessage != null) 'doctor_message': doctorMessage,
    }).eq('id', appointment.id);
  }

  Future<void> rescheduleAsDoctor({
    required Appointment appointment,
    required DateTime newDate,
    required String newTimeSlot,
    String? doctorMessage,
  }) async {
    _enforceOneHourRule(appointment);
    await _client.from('appointments').update({
      'date': Appointment.sqlDateOnly(newDate),
      'time_slot': newTimeSlot,
      'status': AppointmentStatus.rescheduled.name,
      if (doctorMessage != null) 'doctor_message': doctorMessage,
    }).eq('id', appointment.id);
  }

  Future<void> addDoctorMessage({
    required String appointmentId,
    required String doctorMessage,
  }) async {
    await _client
        .from('appointments')
        .update({'doctor_message': doctorMessage})
        .eq('id', appointmentId);
  }

  Future<void> markOngoing(String appointmentId) async {
    await _client
        .from('appointments')
        .update({'status': AppointmentStatus.ongoing.name})
        .eq('id', appointmentId);
  }

  Future<void> markCompleted(String appointmentId) async {
    await _client
        .from('appointments')
        .update({'status': AppointmentStatus.completed.name})
        .eq('id', appointmentId);
  }

  static DateTime _toAppointmentDateTime(Appointment a) {
    final parts = a.timeSlot.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(a.date.year, a.date.month, a.date.day, h, m);
  }

  static void _enforceOneHourRule(Appointment appointment) {
    final appt = _toAppointmentDateTime(appointment);
    final now = DateTime.now();
    final diff = appt.difference(now).inMinutes / 60.0;
    if (diff < 1) {
      throw Exception('Cannot cancel/reschedule within 1 hour of appointment');
    }
  }
}

