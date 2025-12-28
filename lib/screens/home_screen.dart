import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class _Tile {
  final String titleKey;
  final IconData icon;
  final String route;
  const _Tile(this.titleKey, this.icon, this.route);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const tiles = <_Tile>[
    _Tile('generalChildcare', Icons.child_care, '/section/childcare'),
    _Tile('tutorials', Icons.play_circle, '/tutorials'),
    _Tile('spiritualNeeds', Icons.mosque, '/section/spiritual'),
    _Tile('hospitalInfo', Icons.local_hospital, '/section/hospital'),
    _Tile('caregiverSupport', Icons.support_agent, '/section/support'),
    _Tile('trackYourChild', Icons.monitor_heart, '/track'),
    _Tile('heartPrediction', Icons.favorite, '/heart-prediction'),
    _Tile('aiSuggestions', Icons.auto_awesome, '/ai-suggestions'),
    _Tile('aboutChd', Icons.info, '/section/about'),
    _Tile('contacts', Icons.contacts, '/section/contacts'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, i) {
            final t = tiles[i];
            final theme = Theme.of(context);
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(t.route),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              t.icon,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.t(t.titleKey),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
