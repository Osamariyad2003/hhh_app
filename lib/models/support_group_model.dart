class SupportGroupModel {
  final String id;
  final String name;
  final String description;
  final String meetingSchedule;
  final SupportGroupContactInfo contactInfo;
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
      id: json['id']?.toString() ?? '',
      name: json['nameEn']?.toString() ?? json['name']?.toString() ?? '',
      description: json['descriptionEn']?.toString() ?? json['description']?.toString() ?? '',
      meetingSchedule: json['meetingSchedule']?.toString() ?? json['meeting_schedule']?.toString() ?? '',
      contactInfo: json['contactInfo'] is Map<String, dynamic> 
          ? SupportGroupContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>)
          : json['contact_info'] is Map<String, dynamic>
              ? SupportGroupContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>)
              : SupportGroupContactInfo.parse(json['contactInfo']?.toString() ?? json['contact_info']?.toString() ?? ''),
      nameEn: json['nameEn']?.toString(),
      nameAr: json['nameAr']?.toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      descriptionAr: json['descriptionAr']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meetingSchedule': meetingSchedule,
      'contactInfo': contactInfo.toJson(),
      if (nameEn != null) 'nameEn': nameEn,
      if (nameAr != null) 'nameAr': nameAr,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
    };
  }

  String get nameEnglish => nameEn ?? name;
  String get descriptionEnglish => descriptionEn ?? description;

  SupportGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? meetingSchedule,
    SupportGroupContactInfo? contactInfo,
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

class SupportGroupContactInfo {
  final String? phone;
  final String? email;
  final String? organizer;
  final String? website;

  const SupportGroupContactInfo({
    this.phone,
    this.email,
    this.organizer,
    this.website,
  });

  factory SupportGroupContactInfo.fromJson(Map<String, dynamic> json) {
    return SupportGroupContactInfo(
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      organizer: json['organizer']?.toString(),
      website: json['website']?.toString(),
    );
  }

  factory SupportGroupContactInfo.parse(String raw) {
    if (raw.isEmpty) return const SupportGroupContactInfo();
    
    String? phone;
    String? email;
    String? organizer;
    
    final phoneMatch = RegExp(r'phone:\s*([^,]+)').firstMatch(raw);
    if (phoneMatch != null) phone = phoneMatch.group(1)?.trim();
    
    final emailMatch = RegExp(r'email:\s*([^,]+)').firstMatch(raw);
    if (emailMatch != null) email = emailMatch.group(1)?.replaceFirst('}', '').trim();
    
    final organizerMatch = RegExp(r'organizer:\s*([^,]+)').firstMatch(raw);
    if (organizerMatch != null) organizer = organizerMatch.group(1)?.trim();

    if (phone == null && email == null && organizer == null && raw.length > 2) {
      return SupportGroupContactInfo(organizer: raw);
    }

    return SupportGroupContactInfo(
      phone: phone,
      email: email,
      organizer: organizer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (organizer != null) 'organizer': organizer,
      if (website != null) 'website': website,
    };
  }
  
  @override
  String toString() {
    final parts = <String>[];
    if (organizer != null) parts.add('Organizer: $organizer');
    if (phone != null) parts.add('Phone: $phone');
    if (email != null) parts.add('Email: $email');
    return parts.join('\n');
  }
}

