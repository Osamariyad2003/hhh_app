class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isAnonymous;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.isAnonymous = false,
    this.metadata,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      isAnonymous: json['isAnonymous'] ?? json['is_anonymous'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isAnonymous': isAnonymous,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if user is authenticated (not anonymous)
  bool get isAuthenticated => !isAnonymous && id.isNotEmpty;

  /// Get display name (name, email, or "Anonymous")
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    return 'Anonymous';
  }
}

