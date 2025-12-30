class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String parentName;
  final String parentPhone;
  final String? diagnoses;
  final String? healthTracking;
  final String? userId;

  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.parentName,
    required this.parentPhone,
    this.diagnoses,
    this.healthTracking,
    this.userId,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'] as String)
              : DateTime.now(),
      parentName: json['parentName'] as String? ?? json['parent_name'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ?? json['parent_phone'] as String? ?? '',
      diagnoses: json['diagnoses'] as String?,
      healthTracking: json['healthTracking'] as String? ?? json['health_tracking'] as String?,
      userId: json['userId'] as String? ?? json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'parentName': parentName,
      'parentPhone': parentPhone,
      if (diagnoses != null) 'diagnoses': diagnoses,
      if (healthTracking != null) 'healthTracking': healthTracking,
      if (userId != null) 'userId': userId,
    };
  }

  PatientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? parentName,
    String? parentPhone,
    String? diagnoses,
    String? healthTracking,
    String? userId,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      diagnoses: diagnoses ?? this.diagnoses,
      healthTracking: healthTracking ?? this.healthTracking,
      userId: userId ?? this.userId,
    );
  }
}

