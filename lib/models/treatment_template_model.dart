class TreatmentTemplate {
  const TreatmentTemplate({
    required this.id,
    required this.name,
    this.description,
    this.defaultCost = 0,
    this.defaultSittings = 1,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final double defaultCost;
  final int defaultSittings;
  final bool isActive;

  factory TreatmentTemplate.fromJson(Map<String, dynamic> json) =>
      TreatmentTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        defaultCost: (json['default_cost'] as num?)?.toDouble() ?? 0,
        defaultSittings: json['default_sittings'] as int? ?? 1,
        isActive: json['is_active'] as bool? ?? true,
      );
}
