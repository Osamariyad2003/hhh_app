import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';
import '../services/patient_story_service.dart';

class PatientStoriesScreen extends StatelessWidget {
  const PatientStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('patientStories')),
        actions: const [LangToggleButton()],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PatientStoryService.instance.streamPublishedStories().handleError((error) {
          debugPrint('Error loading patient stories from Firebase: $error');
          return <Map<String, dynamic>>[];
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EmptyStateWidget(
              icon: Icons.book_outlined,
              title: 'Loading stories...',
              isLoading: true,
            );
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: loc.t('unableToLoadStories'),
              message: '${loc.t('error')}: ${snapshot.error.toString()}\n\n${loc.t('checkConnection')}',
            );
          }

          if (!snapshot.hasData) {
            return const EmptyStateWidget(
              icon: Icons.book_outlined,
              title: 'Loading stories...',
              isLoading: true,
            );
          }

          final stories = snapshot.data!;
          
          if (stories.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.book_outlined,
              title: loc.t('noStoriesAvailable'),
              message: loc.t('storiesWillAppear'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: stories.length,
            itemBuilder: (context, i) {
              final story = stories[i];
              final title = story['title'] ?? loc.t('story');
              final content = loc.isArabic
                  ? (story['contentArabic'] ?? story['contentEnglish'] ?? '')
                  : (story['contentEnglish'] ?? '');
              final author = story['author'] ?? '';
              final category = story['category'] ?? '';
              final imageUrl = story['imageUrl'] as String?;
              final isFeatured = story['isFeatured'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    _showStoryDetail(context, story, loc);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              loc.isArabic ? 'مميز' : 'Featured',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isFeatured) const SizedBox(height: 12),

                        if (imageUrl != null && imageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        if (author.isNotEmpty || category.isNotEmpty)
                          Row(
                            children: [
                              if (author.isNotEmpty) ...[
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${loc.t('by')} $author',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                              if (author.isNotEmpty && category.isNotEmpty)
                                Text(
                                  ' • ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              if (category.isNotEmpty)
                                Text(
                                  category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        Text(
                          content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              loc.isArabic ? 'اقرأ المزيد' : 'Read more',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStoryDetail(BuildContext context, Map<String, dynamic> story, AppLocalizations loc) {
    final title = story['title'] ?? loc.t('story');
    final content = loc.isArabic
        ? (story['contentArabic'] ?? story['contentEnglish'] ?? '')
        : (story['contentEnglish'] ?? '');
    final author = story['author'] ?? '';
    final category = story['category'] ?? '';
    final imageUrl = story['imageUrl'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      if (author.isNotEmpty || category.isNotEmpty)
                        Row(
                          children: [
                            if (author.isNotEmpty) ...[
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${loc.t('by')} $author',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                            if (author.isNotEmpty && category.isNotEmpty)
                              Text(
                                ' • ',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                            if (category.isNotEmpty)
                              Text(
                                category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.8,
                              fontSize: loc.isArabic ? 18 : 16,
                            ),
                        textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

