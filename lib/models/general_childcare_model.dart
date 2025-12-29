/// Model for General Childcare Information
/// Represents a document from the 'general_childcare' Firestore collection
class GeneralChildcareModel {
  final String id;
  final String title;
  final String description;
  final String category; // growth, nutrition, sleep, hygiene, safety, daily_care, development
  final String? ageRange;
  final String contentType; // text, image, video, link
  final String body;
  final String language; // "en" or "ar"
  final String? mediaUrl;
  final int order;
  final bool isActive;

  const GeneralChildcareModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.ageRange,
    required this.contentType,
    required this.body,
    required this.language,
    this.mediaUrl,
    required this.order,
    required this.isActive,
  });

  /// Create from Firestore document
  factory GeneralChildcareModel.fromJson(Map<String, dynamic> json) {
    return GeneralChildcareModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'daily_care',
      ageRange: json['ageRange'] as String?,
      contentType: json['contentType'] as String? ?? 'text',
      body: json['body'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      mediaUrl: json['mediaUrl'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      if (ageRange != null) 'ageRange': ageRange,
      'contentType': contentType,
      'body': body,
      'language': language,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'order': order,
      'isActive': isActive,
    };
  }

  /// Create a copy with modified fields
  GeneralChildcareModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? ageRange,
    String? contentType,
    String? body,
    String? language,
    String? mediaUrl,
    int? order,
    bool? isActive,
  }) {
    return GeneralChildcareModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      ageRange: ageRange ?? this.ageRange,
      contentType: contentType ?? this.contentType,
      body: body ?? this.body,
      language: language ?? this.language,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get icon based on category
  String get categoryIcon {
    switch (category) {
      case 'growth':
        return 'growth';
      case 'nutrition':
        return 'nutrition';
      case 'sleep':
        return 'sleep';
      case 'hygiene':
        return 'hygiene';
      case 'safety':
        return 'safety';
      case 'daily_care':
        return 'daily_care';
      case 'development':
        return 'development';
      default:
        return 'info';
    }
  }
}

