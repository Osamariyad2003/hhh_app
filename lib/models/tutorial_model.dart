/// Tutorial model based on schema
class TutorialModel {
  final String id;
  final String category; // "formula_mixes", "medication", "post_op_care", "general"
  final String title;
  final String contentEnglish;
  final String? contentArabic;
  final String? videoUrl;
  final String? fileUrl;
  final String imageUrl;

  const TutorialModel({
    required this.id,
    required this.category,
    required this.title,
    required this.contentEnglish,
    this.contentArabic,
    this.videoUrl,
    this.fileUrl,
    required this.imageUrl,
  });

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String,
      title: json['title'] as String,
      contentEnglish: json['contentEnglish'] as String? ?? json['content_english'] as String? ?? '',
      contentArabic: json['contentArabic'] as String? ?? json['content_arabic'] as String?,
      videoUrl: json['videoUrl'] as String? ?? json['video_url'] as String?,
      fileUrl: json['fileUrl'] as String? ?? json['file_url'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'contentEnglish': contentEnglish,
      if (contentArabic != null) 'contentArabic': contentArabic,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      'imageUrl': imageUrl,
    };
  }

  TutorialModel copyWith({
    String? id,
    String? category,
    String? title,
    String? contentEnglish,
    String? contentArabic,
    String? videoUrl,
    String? fileUrl,
    String? imageUrl,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      contentEnglish: contentEnglish ?? this.contentEnglish,
      contentArabic: contentArabic ?? this.contentArabic,
      videoUrl: videoUrl ?? this.videoUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

