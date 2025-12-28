import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';
import '../services/sections_service.dart';
import '../models/section_content.dart';

class SectionScreen extends StatelessWidget {
  final String sectionId;
  const SectionScreen({super.key, required this.sectionId});

  String _pickText(AppLocalizations loc, Map<String, dynamic> block, String keyBase) {
    final ar = block['${keyBase}_ar'];
    final en = block['${keyBase}_en'];
    final v = loc.isArabic ? ar : en;
    return (v ?? '').toString();
  }

  List<String> _pickItems(AppLocalizations loc, Map<String, dynamic> block) {
    final raw = loc.isArabic ? block['items_ar'] : block['items_en'];
    if (raw is List) {
      return raw.map((e) => (e ?? '').toString()).where((s) => s.trim().isNotEmpty).toList();
    }
    return const [];
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _renderBlock(BuildContext context, AppLocalizations loc, Map<String, dynamic> block) {
    final type = (block['type'] ?? '').toString().trim();

    switch (type) {
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );

      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        );

      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );

      case 'bullets':
        final items = _pickItems(loc, block);
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(t)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );

      case 'callout':
        final text = _pickText(loc, block, 'text');
        if (text.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(text),
            ),
          ),
        );

      case 'link':
        final label = _pickText(loc, block, 'label');
        final url = (block['url'] ?? '').toString().trim();
        if (url.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _openLink(url),
            child: Row(
              children: [
                const Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label.trim().isEmpty ? url : label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return StreamBuilder<SectionContent?>(
      stream: SectionsService.instance.streamSection(sectionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Section error:\n${snapshot.error}'),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final section = snapshot.data;
        if (section == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No content found for "$sectionId".'),
              ),
            ),
          );
        }

        final title = loc.isArabic ? section.titleAr : section.titleEn;
        final blocks = section.blocks.map((block) {
          return {
            'type': block.type,
            'text_en': block.textEn,
            'text_ar': block.textAr,
            'label_en': block.labelEn,
            'label_ar': block.labelAr,
            'url': block.url,
            'r2Key': block.r2Key,
            'items_en': null, // Add if needed
            'items_ar': null, // Add if needed
          };
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text((title == null || title.isEmpty) ? sectionId : title),
            actions: const [LangToggleButton()],
          ),
          body: blocks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('This section has no blocks yet.'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: blocks.length,
                  itemBuilder: (context, i) => _renderBlock(context, loc, blocks[i]),
                ),
        );
      },
    );
  }
}
