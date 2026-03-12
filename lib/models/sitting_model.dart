class Sitting {
  const Sitting({
    required this.id,
    required this.visitId,
    required this.treatmentPlanId,
    required this.sittingDate,
    required this.durationStr,
    this.notes,
    this.cost,
    this.status = 'Scheduled',
    this.createdAt,
  });

  final String id;
  final String visitId;
  final String treatmentPlanId;
  final DateTime sittingDate;
  final String durationStr;
  final String? notes;
  final double? cost;
  final String status; // Scheduled, Completed
  final DateTime? createdAt;

  factory Sitting.fromJson(Map<String, dynamic> json) => Sitting(
    id: json['id'] as String,
    visitId: json['visit_id'] as String? ?? '',
    treatmentPlanId: json['treatment_plan_id'] as String,
    sittingDate: DateTime.parse(json['sitting_date'] as String),
    durationStr: json['duration_str'] as String,
    notes: json['notes'] as String?,
    cost: json['cost'] == null ? null : (json['cost'] as num).toDouble(),
    status: json['status'] as String? ?? 'Scheduled',
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'visit_id': visitId,
    'treatment_plan_id': treatmentPlanId,
    'sitting_date': sittingDate.toIso8601String(),
    'duration_str': durationStr,
    if (notes != null) 'notes': notes,
    if (cost != null) 'cost': cost,
    'status': status,
  };

  Sitting copyWith({
    String? id,
    String? visitId,
    String? treatmentPlanId,
    DateTime? sittingDate,
    String? durationStr,
    String? notes,
    double? cost,
    String? status,
    DateTime? createdAt,
  }) => Sitting(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    treatmentPlanId: treatmentPlanId ?? this.treatmentPlanId,
    sittingDate: sittingDate ?? this.sittingDate,
    durationStr: durationStr ?? this.durationStr,
    notes: notes ?? this.notes,
    cost: cost ?? this.cost,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}
