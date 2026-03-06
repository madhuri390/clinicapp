class Prescription {
  const Prescription({
    required this.id,
    required this.visitId,
    this.medicineName,
    this.dosage,
    this.duration,
    this.instructions,
    this.createdAt,
  });

  final String id;
  final String visitId;
  final String? medicineName;
  final String? dosage;
  final String? duration;
  final String? instructions;
  final DateTime? createdAt;

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as String,
        visitId: json['visit_id'] as String,
        medicineName: json['medicine_name'] as String?,
        dosage: json['dosage'] as String?,
        duration: json['duration'] as String?,
        instructions: json['instructions'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'visit_id': visitId,
        if (medicineName != null) 'medicine_name': medicineName,
        if (dosage != null) 'dosage': dosage,
        if (duration != null) 'duration': duration,
        if (instructions != null) 'instructions': instructions,
      };
}
