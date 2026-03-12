import 'payment_model.dart';

class FileAttachment {
  const FileAttachment({
    required this.id,
    this.visitId,
    this.treatmentPlanId,
    this.fileName,
    this.fileType,
    this.fileUrl,
    this.price,
    this.payment,
    this.createdAt,
  });

  final String id;
  final String? visitId;
  final String? treatmentPlanId;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  final double? price;
  final Payment? payment;
  final DateTime? createdAt;

  FileAttachment copyWith({
    String? id,
    String? visitId,
    String? treatmentPlanId,
    String? fileName,
    String? fileType,
    String? fileUrl,
    double? price,
    Payment? payment,
    DateTime? createdAt,
  }) {
    return FileAttachment(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      treatmentPlanId: treatmentPlanId ?? this.treatmentPlanId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      price: price ?? this.price,
      payment: payment ?? this.payment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FileAttachment.fromJson(Map<String, dynamic> json) => FileAttachment(
    id: json['id'] as String,
    visitId: json['visit_id'] as String?,
    treatmentPlanId: json['treatment_plan_id'] as String?,
    fileName: json['file_name'] as String?,
    fileType: json['file_type'] as String?,
    fileUrl: json['file_url'] as String?,
    price: json['price'] == null ? null : (json['price'] as num).toDouble(),
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    if (visitId != null) 'visit_id': visitId,
    if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
    if (fileName != null) 'file_name': fileName,
    if (fileType != null) 'file_type': fileType,
    if (fileUrl != null) 'file_url': fileUrl,
    if (price != null) 'price': price,
  };
}
