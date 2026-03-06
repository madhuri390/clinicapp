class Payment {
  const Payment({
    required this.id,
    required this.treatmentPlanId,
    required this.amountPaid,
    this.paymentMode,
    this.paymentDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String treatmentPlanId;
  final double amountPaid;
  /// One of: Cash | UPI | Card
  final String? paymentMode;
  final DateTime? paymentDate;
  final String? notes;
  final DateTime? createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        treatmentPlanId: json['treatment_plan_id'] as String,
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
        'treatment_plan_id': treatmentPlanId,
        'amount_paid': amountPaid,
        if (paymentMode != null) 'payment_mode': paymentMode,
        'payment_date': (paymentDate ?? DateTime.now()).toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
