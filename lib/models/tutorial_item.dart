class TutorialItem {
  final String id;

  final String type;

  final String titleEn;
  final String titleAr;
  final String? descriptionEn;
  final String? descriptionAr;

  final String? url;
  final String? r2Key;

  final int? order;

  final bool enabled;
  final String? category;
  final DateTime? updatedAt;

  const TutorialItem({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.url,
    this.r2Key,
    this.order,
    this.enabled = true,
    this.category,
    this.updatedAt,
  });


  static String _readString(
    Map<String, dynamic> data,
    String camel,
    String snake,
  ) {
    final v = data[camel] ?? data[snake];
    return (v ?? '').toString();
  }

  static String? _readNullableString(
    Map<String, dynamic> data,
    String camel,
    String snake,
  ) {
    final v = data[camel] ?? data[snake];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _readInt(Map<String, dynamic> data, String camel, String snake) {
    final v = data[camel] ?? data[snake];
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool _readBool(
    Map<String, dynamic> data,
    String camel,
    String snake, {
    bool defaultValue = true,
  }) {
    final v = data[camel] ?? data[snake];
    if (v == null) return defaultValue;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return defaultValue;
  }

  static DateTime? _readDateTime(
    Map<String, dynamic> data,
    String camel,
    String snake,
  ) {
    final v = data[camel] ?? data[snake];
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) {
      try {
        return DateTime.parse(v); 
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory TutorialItem.fromJson(Map<String, dynamic> data) {
    final id = _readString(data, 'id', 'id');

    final type = _readString(data, 'type', 'type');

    final titleEn = _readString(data, 'titleEn', 'title_en');
    final titleAr = _readString(data, 'titleAr', 'title_ar');

    final descriptionEn = _readNullableString(
      data,
      'descriptionEn',
      'description_en',
    );
    final descriptionAr = _readNullableString(
      data,
      'descriptionAr',
      'description_ar',
    );

    final url = _readNullableString(data, 'url', 'url');
    final r2Key = _readNullableString(data, 'r2Key', 'r2_key');

    final order = _readInt(data, 'order', 'order');

    final enabled = _readBool(data, 'enabled', 'enabled', defaultValue: true);
    final category = _readNullableString(data, 'category', 'category');
    final updatedAt = _readDateTime(data, 'updatedAt', 'updated_at');

    return TutorialItem(
      id: id,
      type: type,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      url: url,
      r2Key: r2Key,
      order: order,
      enabled: enabled,
      category: category,
      updatedAt: updatedAt,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title_en': titleEn,
      'title_ar': titleAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'url': url,
      'r2_key': r2Key,
      'order': order,
      'enabled': enabled,
      'category': category,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
