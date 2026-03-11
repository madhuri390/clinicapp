class Visit {
  const Visit({
    required this.id,
    required this.patientId,
    required this.visitDate,
    this.chiefComplaint,
    this.diagnosis,
    this.notes,
    this.nextVisitDate,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final DateTime visitDate;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? notes;
  final DateTime? nextVisitDate;
  final DateTime? createdAt;

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        visitDate: DateTime.parse(json['visit_date'] as String),
        chiefComplaint: json['chief_complaint'] as String?,
        diagnosis: json['diagnosis'] as String?,
        notes: json['notes'] as String?,
        nextVisitDate: json['next_visit_date'] == null
            ? null
            : DateTime.tryParse(json['next_visit_date'] as String),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'] as String),
      );

  Map<String, dynamic> toInsertJson() => {
        'patient_id': patientId,
        'visit_date': visitDate.toIso8601String(),
        if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
        if (diagnosis != null) 'diagnosis': diagnosis,
        if (notes != null) 'notes': notes,
        if (nextVisitDate != null)
          'next_visit_date': nextVisitDate!.toIso8601String(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'visit_date': visitDate.toIso8601String(),
        'chief_complaint': chiefComplaint,
        'diagnosis': diagnosis,
        'notes': notes,
        'next_visit_date': nextVisitDate?.toIso8601String(),
      };
}
