/// Support Group model based on schema
class SupportGroupModel {
  final String id;
  final String name;
  final String description;
  final String meetingSchedule;
  final String contactInfo;

  const SupportGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.meetingSchedule,
    required this.contactInfo,
  });

  factory SupportGroupModel.fromJson(Map<String, dynamic> json) {
    return SupportGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      meetingSchedule: json['meetingSchedule'] as String? ?? json['meeting_schedule'] as String? ?? '',
      contactInfo: json['contactInfo'] as String? ?? json['contact_info'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meetingSchedule': meetingSchedule,
      'contactInfo': contactInfo,
    };
  }

  SupportGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? meetingSchedule,
    String? contactInfo,
  }) {
    return SupportGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

