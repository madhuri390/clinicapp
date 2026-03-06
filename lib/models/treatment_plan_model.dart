class TreatmentPlan {
  const TreatmentPlan({
    required this.id,
    required this.visitId,
    this.treatmentName,
    this.description,
    this.totalCost,
    this.status = 'planned',
    this.createdAt,
  });

  final String id;
  final String visitId;
  final String? treatmentName;
  final String? description;
  final double? totalCost;
  /// One of: planned | in_progress | completed | discontinued
  final String? status;
  final DateTime? createdAt;

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) => TreatmentPlan(
        id: json['id'] as String,
        visitId: json['visit_id'] as String,
        treatmentName: json['treatment_name'] as String?,
        description: json['description'] as String?,
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
        if (totalCost != null) 'total_cost': totalCost,
        'status': status ?? 'planned',
      };

  TreatmentPlan copyWith({String? status}) => TreatmentPlan(
        id: id,
        visitId: visitId,
        treatmentName: treatmentName,
        description: description,
        totalCost: totalCost,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
