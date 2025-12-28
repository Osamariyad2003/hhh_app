class SectionContent {
  final String id;
  final String titleEn;
  final String titleAr;
  final List<SectionBlock> blocks;

  const SectionContent({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.blocks,
  });

  static String _s(Map<String, dynamic> data, String camel, String snake) {
    final v = data[camel] ?? data[snake];
    return (v ?? '').toString();
  }

  static String? _sn(Map<String, dynamic> data, String camel, String snake) {
    final v = data[camel] ?? data[snake];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  factory SectionContent.fromMap(String id, Map<String, dynamic> data) {
    final titleEn = _s(data, 'titleEn', 'title_en');
    final titleAr = _s(data, 'titleAr', 'title_ar');

    final rawBlocks = data['blocks'];
    final blocks = <SectionBlock>[];
    if (rawBlocks is List) {
      for (final b in rawBlocks) {
        if (b is Map) {
          blocks.add(SectionBlock.fromMap(Map<String, dynamic>.from(b)));
        }
      }
    }

    return SectionContent(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      blocks: blocks,
    );
  }
}

class SectionBlock {
  final String type;

  final String? textEn;
  final String? textAr;

  final String? labelEn;
  final String? labelAr;

  final String? url;
  final String? r2Key;

  const SectionBlock({
    required this.type,
    this.textEn,
    this.textAr,
    this.labelEn,
    this.labelAr,
    this.url,
    this.r2Key,
  });

  static String _s(Map<String, dynamic> data, String camel, String snake) {
    final v = data[camel] ?? data[snake];
    return (v ?? '').toString();
  }

  static String? _sn(Map<String, dynamic> data, String camel, String snake) {
    final v = data[camel] ?? data[snake];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  factory SectionBlock.fromMap(Map<String, dynamic> data) {
    final type = _s(data, 'type', 'type');

    return SectionBlock(
      type: type,
      textEn: _sn(data, 'textEn', 'text_en'),
      textAr: _sn(data, 'textAr', 'text_ar'),
      labelEn: _sn(data, 'labelEn', 'label_en'),
      labelAr: _sn(data, 'labelAr', 'label_ar'),
      url: _sn(data, 'url', 'url'),
      r2Key: _sn(data, 'r2Key', 'r2Key'),
    );
  }
}
