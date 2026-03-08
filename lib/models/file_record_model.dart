class FileRecord {
  const FileRecord({
    required this.id,
    this.treatmentPlanId,
    this.visitId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    this.createdAt,
  });

  final String id;
  final String? treatmentPlanId;
  final String? visitId;
  final String fileName;
  final String fileType; // E.g., 'X-Ray', 'CBCT Scan', 'Report'
  final String fileUrl;
  final DateTime? createdAt;

  factory FileRecord.fromJson(Map<String, dynamic> json) => FileRecord(
    id: json['id'] as String,
    treatmentPlanId: json['treatment_plan_id'] as String?,
    visitId: json['visit_id'] as String?,
    fileName: json['file_name'] as String,
    fileType: json['file_type'] as String,
    fileUrl: json['file_url'] as String,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
    if (visitId != null) 'visit_id': visitId,
    'file_name': fileName,
    'file_type': fileType,
    'file_url': fileUrl,
  };
}
