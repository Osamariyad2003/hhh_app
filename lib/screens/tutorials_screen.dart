import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/r2_config.dart';
import '../localization/app_localizations.dart';
import '../models/tutorial_item.dart';
import '../services/tutorials_service.dart';
import '../widgets/lang_toggle_button.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  String? _resolveUrl(TutorialItem item) {
    if (item.type == 'url') return item.url;

    if (item.type == 'r2') {
      final key = (item.r2Key ?? '').trim();
      if (key.isEmpty) return null;

      final base = kR2PublicBaseUrl.trim();
      if (base.isEmpty || base.contains('YOUR_R2_PUBLIC_DOMAIN')) return null;

      final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final normalizedKey = key.startsWith('/') ? key.substring(1) : key;

      return '$normalizedBase/$normalizedKey';
    }

    return null;
  }

  Future<void> _openTutorial(TutorialItem item) async {
    final url = _resolveUrl(item);
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('tutorials')),
        actions: const [LangToggleButton()],
      ),
      body: StreamBuilder<List<TutorialItem>>(
        stream: TutorialsService.instance.streamTutorials(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Tutorials error:\n${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!;
          if (items.isEmpty) return Center(child: Text(loc.t('tutorialsEmpty')));

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = items[i];
              final title = loc.isArabic ? item.titleAr : item.titleEn;
              final desc = loc.isArabic ? item.descriptionAr : item.descriptionEn;

              return ListTile(
                title: Text(title.isEmpty ? '(untitled)' : title),
                subtitle: (desc == null || desc.isEmpty) ? null : Text(desc),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openTutorial(item),
              );
            },
          );
        },
      ),
    );
  }
}
