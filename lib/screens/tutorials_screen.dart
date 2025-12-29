import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/r2_config.dart';
import '../localization/app_localizations.dart';
import '../models/tutorial_item.dart';
import '../services/tutorials_service.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';

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

  Future<void> _openTutorial(BuildContext context, TutorialItem item) async {
    // Navigate to detail screen
    context.push('/tutorial/${item.id}', extra: item);
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
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Unable to load tutorials',
              message: 'Please check your connection and try again.',
            );
          }
          if (!snapshot.hasData) {
            return const EmptyStateWidget(
              icon: Icons.play_circle_outline,
              title: 'Loading tutorials...',
              isLoading: true,
            );
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.video_library_outlined,
              title: loc.t('tutorialsEmpty'),
              message: 'Tutorials will appear here once they are available.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = items[i];
              final title = loc.isArabic ? item.titleAr : item.titleEn;
              final desc = loc.isArabic ? item.descriptionAr : item.descriptionEn;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.play_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    title.isEmpty ? '(untitled)' : title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: (desc == null || desc.isEmpty)
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            desc,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _openTutorial(context, item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
