import 'payment_model.dart';

class Prescription {
  const Prescription({
    required this.id,
    this.visitId,
    this.treatmentPlanId,
    this.sittingId,
    this.medicineName,
    this.dosage,
    this.duration,
    this.instructions,
    this.price,
    this.payment,
    this.createdAt,
  });

  final String id;
  final String? visitId;
  final String? treatmentPlanId;
  final String? sittingId;
  final String? medicineName;
  final String? dosage;
  final String? duration;
  final String? instructions;
  final double? price;
  final Payment? payment;
  final DateTime? createdAt;

  Prescription copyWith({Payment? payment}) {
    return Prescription(
      id: id,
      visitId: visitId,
      treatmentPlanId: treatmentPlanId,
      sittingId: sittingId,
      medicineName: medicineName,
      dosage: dosage,
      duration: duration,
      instructions: instructions,
      price: price,
      payment: payment ?? this.payment,
      createdAt: createdAt,
    );
  }

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json['id'] as String,
    visitId: json['visit_id'] as String?,
    treatmentPlanId: json['treatment_plan_id'] as String?,
    sittingId: json['sitting_id'] as String?,
    medicineName: json['medicine_name'] as String?,
    dosage: json['dosage'] as String?,
    duration: json['duration'] as String?,
    instructions: json['instructions'] as String?,
    price: json['price'] == null ? null : (json['price'] as num).toDouble(),
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    if (visitId != null) 'visit_id': visitId,
    if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
    if (sittingId != null) 'sitting_id': sittingId,
    if (medicineName != null) 'medicine_name': medicineName,
    if (dosage != null) 'dosage': dosage,
    if (duration != null) 'duration': duration,
    if (instructions != null) 'instructions': instructions,
    if (price != null) 'price': price,
  };
}
