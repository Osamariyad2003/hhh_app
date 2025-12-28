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
    _Tile('spiritualNeeds', Icons.volunteer_activism, '/section/spiritual'),
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
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, i) {
            final t = tiles[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(t.route),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          loc.t(t.titleKey),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
