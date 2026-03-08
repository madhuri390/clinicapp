class Payment {
  const Payment({
    required this.id,
    required this.visitId,
    this.treatmentPlanId,
    this.sittingId,
    this.prescriptionId,
    this.fileId,
    required this.amountPaid,
    this.paymentMode,
    this.paymentDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String visitId;
  final String? treatmentPlanId;
  final String? sittingId;
  final String? prescriptionId;
  final String? fileId;
  final double amountPaid;

  /// One of: Cash | UPI | Card
  final String? paymentMode;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime? createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    visitId: json['visit_id'] as String? ?? '',
    treatmentPlanId: json['treatment_plan_id'] as String?,
    sittingId: json['sitting_id'] as String?,
    prescriptionId: json['prescription_id'] as String?,
    fileId: json['file_id'] as String?,
    amountPaid: (json['amount_paid'] as num).toDouble(),
    paymentMode: json['payment_mode'] as String?,
    paymentDate: json['payment_date'] == null
        ? null
        : DateTime.tryParse(json['payment_date'] as String),
    notes: json['notes'] as String?,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'visit_id': visitId,
    if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
    if (sittingId != null) 'sitting_id': sittingId,
    if (prescriptionId != null) 'prescription_id': prescriptionId,
    if (fileId != null) 'file_id': fileId,
    'amount_paid': amountPaid,
    if (paymentMode != null) 'payment_mode': paymentMode,
    'payment_date': (paymentDate ?? DateTime.now()).toIso8601String(),
    if (notes != null) 'notes': notes,
  };
}
