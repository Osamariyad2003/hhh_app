import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class ChildInfoScreen extends StatelessWidget {
  final String childId;
  const ChildInfoScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('trackYourChild')),
        actions: const [LangToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildTrackingCard(
              context,
              theme,
              icon: Icons.restaurant,
              iconColor: Colors.green,
              backgroundColor: Colors.green.shade50,
              title: loc.isArabic ? 'التغذية' : 'Nutrition',
              onTap: () => context.push('/track/child/$childId?tab=feeding'),
            ),
            _buildTrackingCard(
              context,
              theme,
              icon: Icons.scale,
              iconColor: Colors.blue,
              backgroundColor: Colors.blue.shade50,
              title: loc.isArabic ? 'الوزن' : 'Weight',
              onTap: () => context.push('/track/child/$childId?tab=weight'),
            ),
            _buildTrackingCard(
              context,
              theme,
              icon: Icons.medical_services,
              iconColor: Colors.orange,
              backgroundColor: Colors.orange.shade50,
              title: loc.isArabic ? 'المعدات' : 'Equipment',
              onTap: () {
                // Navigate to equipment screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.isArabic ? 'قريباً' : 'Coming soon')),
                );
              },
            ),
            _buildTrackingCard(
              context,
              theme,
              icon: Icons.favorite,
              iconColor: Colors.red,
              backgroundColor: Colors.pink.shade50,
              title: loc.isArabic ? 'تشبع الأكسجين' : 'Oxygen Saturation',
              onTap: () => context.push('/track/child/$childId?tab=oxygen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

