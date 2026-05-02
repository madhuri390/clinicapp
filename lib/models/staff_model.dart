class Staff {
  final String id;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  final String? workStartTime;
  final String? workEndTime;
  final String? authUserId;
  final String? username;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Staff({
    required this.id,
    required this.name,
    this.role = 'General Dentist',
    this.phone,
    this.email,
    this.workStartTime,
    this.workEndTime,
    this.authUserId,
    this.username,
    this.createdAt,
    this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    final fName = json['first_name'] as String? ?? '';
    final lName = json['last_name'] as String? ?? '';
    final fullName = lName.isEmpty ? fName : '$fName $lName';
    
    return Staff(
      id: json['id'] as String,
      name: fullName,
      role: json['specialisation'] as String? ?? 'General Dentist',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      workStartTime: json['work_start_time'] as String?,
      workEndTime: json['work_end_time'] as String?,
      authUserId: json['auth_user_id'] as String?,
      username: json['username'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final nameParts = name.trim().split(' ');
    final fName = nameParts.first;
    final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return {
      if (id.isNotEmpty) 'id': id,
      'first_name': fName,
      'last_name': lName,
      'specialisation': role,
      'phone': phone,
      'email': email,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      if (username != null && username!.isNotEmpty) 'username': username,
      if (authUserId != null) 'auth_user_id': authUserId,
    };
  }

  Staff copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    String? email,
    String? workStartTime,
    String? workEndTime,
    String? authUserId,
    String? username,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      authUserId: authUserId ?? this.authUserId,
      username: username ?? this.username,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
