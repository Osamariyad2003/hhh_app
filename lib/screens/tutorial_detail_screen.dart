import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../models/tutorial_item.dart';
import '../widgets/lang_toggle_button.dart';

class TutorialDetailScreen extends StatelessWidget {
  final TutorialItem tutorial;

  const TutorialDetailScreen({
    super.key,
    required this.tutorial,
  });

  String? _extractYouTubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;

    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]{11})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  String _getYouTubeEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId';
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = loc.isArabic ? tutorial.titleAr : tutorial.titleEn;
    final description = loc.isArabic ? tutorial.descriptionAr : tutorial.descriptionEn;

    String? videoUrl;
    if (tutorial.type == 'url') {
      videoUrl = tutorial.url;
    } else if (tutorial.type == 'r2' && tutorial.r2Key != null) {
      videoUrl = tutorial.r2Key;
    }

    final youtubeVideoId = _extractYouTubeVideoId(videoUrl);
    final isYouTube = youtubeVideoId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('tutorials')),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isYouTube)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'YouTube Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openInBrowser(videoUrl!),
                            icon: const Icon(Icons.open_in_new),
                            label: Text(loc.t('watchOnYouTube')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (videoUrl != null && videoUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openInBrowser(videoUrl!),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(loc.t('openVideo')),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? '(untitled)' : title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (description != null && description.isNotEmpty) ...[
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (isYouTube) ...[
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is a YouTube video. Tap the button above to watch it in the YouTube app or browser.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (videoUrl != null && videoUrl.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInBrowser(videoUrl!),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(isYouTube ? 'Watch on YouTube' : 'Open Video'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

