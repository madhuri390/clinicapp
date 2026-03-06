class Patient {
  const Patient({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.phone,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.medicalHistory,
    this.dentalHistory,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String phone;
  final String? email;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? address;
  final String? medicalHistory;
  final String? dentalHistory;
  final DateTime? createdAt;

  String get fullName =>
      [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int a = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      a--;
    }
    return a;
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.tryParse(json['date_of_birth'] as String),
      bloodGroup: json['blood_group'] as String?,
      address: json['address'] as String?,
      medicalHistory: json['medical_history'] as String?,
      dentalHistory: json['dental_history'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
    'phone': phone,
    if (email != null) 'email': email,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null)
      'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
    if (bloodGroup != null) 'blood_group': bloodGroup,
    if (address != null) 'address': address,
    if (medicalHistory != null) 'medical_history': medicalHistory,
    if (dentalHistory != null) 'dental_history': dentalHistory,
  };
}
