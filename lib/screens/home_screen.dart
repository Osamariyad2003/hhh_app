import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final quoteKeys = [
      'quote1',
      'quote2',
      'quote3',
      'quote4',
      'quote5',
    ];
    final quoteKey = quoteKeys[DateTime.now().day % quoteKeys.length];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('appTitle')),
        actions: [
          IconButton(
            tooltip: loc.t('settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          const LangToggleButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('welcome'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.t('caregiverSupportSubtitle'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _HomeCard(
              title: loc.t('quoteOfTheDay'),
              icon: Icons.format_quote,
              color: theme.colorScheme.secondaryContainer,
              onTap: () {}, 
              child: Text(
                '"${loc.t(quoteKey)}"',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _HomeCard(
                    title: loc.t('trackYourChild'),
                    icon: Icons.monitor_heart,
                    color: theme.colorScheme.surface,
                    showBorder: true,
                    onTap: () => context.go('/track'),
                    child: Text(
                        loc.t('checkConnection'), 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                    ), 
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HomeCard(
                    title: loc.t('aiSuggestions'),
                    icon: Icons.auto_awesome,
                    color: theme.colorScheme.surface,
                    showBorder: true,
                    onTap: () => context.push('/ai-suggestions'),
                    child: Text(
                      loc.t('getPersonalizedTips'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 16),
             
             _HomeCard(
               title: loc.t('tutorials'),
               icon: Icons.play_circle_fill,
               color: theme.colorScheme.tertiaryContainer,
               onTap: () => context.push('/tutorials'),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     loc.t('featuredCHD'),
                     style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 4),
                   Text(loc.t('watchGuide')),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final bool showBorder;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    required this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: showBorder
              ? Border.all(color: theme.colorScheme.outline.withOpacity(0.2))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
