import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/general_childcare_model.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class ChildcareDetailScreen extends StatelessWidget {
  final GeneralChildcareModel item;

  const ChildcareDetailScreen({
    super.key,
    required this.item,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'growth':
        return Icons.trending_up;
      case 'nutrition':
        return Icons.restaurant;
      case 'sleep':
        return Icons.bedtime;
      case 'hygiene':
        return Icons.clean_hands;
      case 'safety':
        return Icons.shield;
      case 'daily_care':
        return Icons.favorite;
      case 'development':
        return Icons.child_care;
      default:
        return Icons.info;
    }
  }

  String _getCategoryName(String category, AppLocalizations loc) {
    switch (category) {
      case 'growth':
        return loc.t('growth');
      case 'nutrition':
        return loc.t('nutrition');
      case 'sleep':
        return loc.t('sleep');
      case 'hygiene':
        return loc.t('hygiene');
      case 'safety':
        return loc.t('safety');
      case 'daily_care':
        return loc.t('dailyCare');
      case 'development':
        return loc.t('development');
      default:
        return category;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = loc.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('generalChildcare')),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(item.category),
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryName(item.category, loc),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              item.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 12),

            Text(
              item.description,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),

            if (item.ageRange != null && item.ageRange!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.ageRange!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            _buildContent(context, theme, isArabic, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
    AppLocalizations loc,
  ) {
    switch (item.contentType) {
      case 'text':
        return _buildTextContent(theme, isArabic);

      case 'image':
        return _buildImageContent(context, theme, isArabic);

      case 'video':
        return _buildVideoContent(context, theme, isArabic, loc);

      case 'link':
        return _buildLinkContent(context, theme, isArabic, loc);

      default:
        return _buildTextContent(theme, isArabic);
    }
  }

  Widget _buildTextContent(ThemeData theme, bool isArabic) {
    return Text(
      item.body,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.8,
        fontSize: isArabic ? 18 : 16,
      ),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
    );
  }

  Widget _buildImageContent(
      BuildContext context, ThemeData theme, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.mediaUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: theme.colorScheme.errorContainer,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          item.body,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.8,
            fontSize: isArabic ? 18 : 16,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
    AppLocalizations loc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) ...[
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _launchURL(item.mediaUrl!),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _launchURL(item.mediaUrl!),
            icon: const Icon(Icons.play_arrow),
            label: Text(loc.t('watchVideo')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          item.body,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.8,
            fontSize: isArabic ? 18 : 16,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildLinkContent(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
    AppLocalizations loc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.body,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.8,
            fontSize: isArabic ? 18 : 16,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        if (item.mediaUrl != null && item.mediaUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _launchURL(item.mediaUrl!),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.t('openLink'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.mediaUrl!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

