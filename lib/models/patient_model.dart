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
    /// Same as [id] when this row is the logged-in auth user (patient portal).
    this.authUserId,
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

  /// Supabase `auth.users.id` when linked to patient portal login.
  final String? authUserId;

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
      authUserId: json['auth_user_id'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    if (id.isNotEmpty) 'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'email': email,
    'gender': gender,
    'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
    'blood_group': bloodGroup,
    'address': address,
    'medical_history': medicalHistory,
    'dental_history': dentalHistory,
    if (authUserId != null) 'auth_user_id': authUserId,
  };

  Map<String, dynamic> toUpdateJson() {
    final map = toInsertJson();
    map.remove('id');
    map.remove('created_at');
    return map;
  }
}
