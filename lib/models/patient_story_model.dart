class PatientStoryModel {
  final String id;
  final String title;
  final String contentEnglish;
  final String contentArabic;
  final String author;
  final String category;
  final bool isPublished;
  final bool isFeatured;
  final String? imageUrl;

  const PatientStoryModel({
    required this.id,
    required this.title,
    required this.contentEnglish,
    required this.contentArabic,
    required this.author,
    required this.category,
    required this.isPublished,
    required this.isFeatured,
    this.imageUrl,
  });

  factory PatientStoryModel.fromJson(Map<String, dynamic> json) {
    return PatientStoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      contentEnglish: json['contentEnglish'] as String? ?? json['content_english'] as String? ?? '',
      contentArabic: json['contentArabic'] as String? ?? json['content_arabic'] as String? ?? '',
      author: json['author'] as String,
      category: json['category'] as String,
      isPublished: json['isPublished'] as bool? ?? json['is_published'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? json['is_featured'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'contentEnglish': contentEnglish,
      'contentArabic': contentArabic,
      'author': author,
      'category': category,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  PatientStoryModel copyWith({
    String? id,
    String? title,
    String? contentEnglish,
    String? contentArabic,
    String? author,
    String? category,
    bool? isPublished,
    bool? isFeatured,
    String? imageUrl,
  }) {
    return PatientStoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contentEnglish: contentEnglish ?? this.contentEnglish,
      contentArabic: contentArabic ?? this.contentArabic,
      author: author ?? this.author,
      category: category ?? this.category,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

