class FirebaseUserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastLogin;

  const FirebaseUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastLogin,
  });

  factory FirebaseUserModel.fromJson(Map<String, dynamic> json) {
    return FirebaseUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : json['last_login'] != null
              ? DateTime.parse(json['last_login'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'isActive': isActive,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
    };
  }

  FirebaseUserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return FirebaseUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

