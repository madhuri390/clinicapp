class TreatmentPlan {
  const TreatmentPlan({
    required this.id,
    required this.visitId,
    this.treatmentName,
    this.description,
    this.teeth,
    this.totalCost,
    this.status = 'planned',
    this.createdAt,
  });

  final String id;
  final String visitId;
  final String? treatmentName;
  final String? description;
  /// Teeth numbers (FDI) for this treatment (e.g. "16, 18").
  final String? teeth;
  final double? totalCost;

  /// One of: planned | in_progress | completed | discontinued
  final String? status;
  final DateTime? createdAt;

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) => TreatmentPlan(
    id: json['id'] as String,
    visitId: json['visit_id'] as String,
    treatmentName: json['treatment_name'] as String?,
    description: json['description'] as String?,
    teeth: json['teeth'] as String?,
    totalCost: (json['total_cost'] as num?)?.toDouble(),
    status: json['status'] as String? ?? 'planned',
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'visit_id': visitId,
    if (treatmentName != null) 'treatment_name': treatmentName,
    if (description != null) 'description': description,
    if (teeth != null) 'teeth': teeth,
    if (totalCost != null) 'total_cost': totalCost,
    'status': status ?? 'planned',
  };

  TreatmentPlan copyWith({
    String? id,
    String? visitId,
    String? treatmentName,
    String? description,
    String? teeth,
    double? totalCost,
    String? status,
    DateTime? createdAt,
  }) => TreatmentPlan(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    treatmentName: treatmentName ?? this.treatmentName,
    description: description ?? this.description,
    teeth: teeth ?? this.teeth,
    totalCost: totalCost ?? this.totalCost,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}
