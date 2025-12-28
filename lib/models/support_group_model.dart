/// Support Group model based on schema
class SupportGroupModel {
  final String id;
  final String name;
  final String description;
  final String meetingSchedule;
  final String contactInfo;
  
  // Bilingual fields (prefer English)
  final String? nameEn;
  final String? nameAr;
  final String? descriptionEn;
  final String? descriptionAr;

  const SupportGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.meetingSchedule,
    required this.contactInfo,
    this.nameEn,
    this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
  });

  factory SupportGroupModel.fromJson(Map<String, dynamic> json) {
    return SupportGroupModel(
      id: json['id'] as String,
      name: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      description: json['descriptionEn'] as String? ?? json['description'] as String? ?? '',
      meetingSchedule: json['meetingSchedule'] as String? ?? json['meeting_schedule'] as String? ?? '',
      contactInfo: json['contactInfo'] as String? ?? json['contact_info'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      nameAr: json['nameAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meetingSchedule': meetingSchedule,
      'contactInfo': contactInfo,
      if (nameEn != null) 'nameEn': nameEn,
      if (nameAr != null) 'nameAr': nameAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
    };
  }

  /// Get English name (preferred)
  String get nameEnglish => nameEn ?? name;
  
  /// Get English description (preferred)
  String get descriptionEnglish => descriptionEn ?? description;

  SupportGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? meetingSchedule,
    String? contactInfo,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
  }) {
    return SupportGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      contactInfo: contactInfo ?? this.contactInfo,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
    );
  }
}

