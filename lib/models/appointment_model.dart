/// Status of an appointment.
enum AppointmentStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
  rescheduled,
}

/// Represents a single dental appointment.
class Appointment {
  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.date,
    required this.timeSlot,
    this.duration = 30,
    required this.type,
    required this.doctorName,
    this.doctorMessage,
    this.status = AppointmentStatus.scheduled,
    this.treatmentPlanId,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final DateTime date;

  /// Time slot in 24-hour format, e.g. "09:00", "14:30".
  final String timeSlot;

  /// Duration in minutes (multiples of 30).
  final int duration;

  /// Treatment/procedure type, e.g. "Root Canal", "Cleaning".
  final String type;

  final String doctorName;

  /// Doctor's comment — set when rescheduling or cancelling.
  final String? doctorMessage;

  final AppointmentStatus status;

  /// If auto-generated from a treatment plan, stores the plan ID.
  final String? treatmentPlanId;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Time slot end derived from [timeSlot] + [duration].
  String get timeSlotEnd {
    final parts = timeSlot.split(':');
    final startHour = int.parse(parts[0]);
    final startMin = int.parse(parts[1]);
    final totalMinutes = startHour * 60 + startMin + duration;
    final endHour = (totalMinutes ~/ 60).clamp(0, 23);
    final endMin = totalMinutes % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }

  /// Human-readable time range, e.g. "09:00 AM - 10:00 AM".
  String get timeRange {
    return '${to12Hour(timeSlot)} - ${to12Hour(timeSlotEnd)}';
  }

  static String to12Hour(String time24) {
    final parts = time24.split(':');
    var h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }
    return '$h:$m $period';
  }

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.ongoing:
        return 'Ongoing';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    DateTime? date,
    String? timeSlot,
    int? duration,
    String? type,
    String? doctorName,
    String? doctorMessage,
    AppointmentStatus? status,
    String? treatmentPlanId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      doctorName: doctorName ?? this.doctorName,
      doctorMessage: doctorMessage ?? this.doctorMessage,
      status: status ?? this.status,
      treatmentPlanId: treatmentPlanId ?? this.treatmentPlanId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'date': date.toIso8601String(),
        'time_slot': timeSlot,
        'duration': duration,
        'type': type,
        'doctor_name': doctorName,
        if (doctorMessage != null) 'doctor_message': doctorMessage,
        'status': status.name,
        if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      patientPhone: json['patient_phone'] as String,
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['time_slot'] as String,
      duration: json['duration'] as int? ?? 30,
      type: json['type'] as String,
      doctorName: json['doctor_name'] as String,
      doctorMessage: json['doctor_message'] as String?,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'scheduled'),
        orElse: () => AppointmentStatus.scheduled,
      ),
      treatmentPlanId: json['treatment_plan_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
