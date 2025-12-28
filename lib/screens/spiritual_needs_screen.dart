import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class SpiritualNeedsScreen extends StatelessWidget {
  const SpiritualNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Five daily prayers with their raka'at
    final prayers = [
      {
        'nameEn': 'Fajr (Dawn)',
        'nameAr': 'الفجر',
        'time': 'Before sunrise',
        'timeAr': 'قبل شروق الشمس',
        'rakaat': 2,
        'sunnahBefore': 2,
        'sunnahAfter': 0,
      },
      {
        'nameEn': 'Dhuhr (Noon)',
        'nameAr': 'الظهر',
        'time': 'After midday',
        'timeAr': 'بعد منتصف النهار',
        'rakaat': 4,
        'sunnahBefore': 4,
        'sunnahAfter': 2,
      },
      {
        'nameEn': 'Asr (Afternoon)',
        'nameAr': 'العصر',
        'time': 'Late afternoon',
        'timeAr': 'بعد العصر',
        'rakaat': 4,
        'sunnahBefore': 0,
        'sunnahAfter': 0,
      },
      {
        'nameEn': 'Maghrib (Sunset)',
        'nameAr': 'المغرب',
        'time': 'After sunset',
        'timeAr': 'بعد غروب الشمس',
        'rakaat': 3,
        'sunnahBefore': 0,
        'sunnahAfter': 2,
      },
      {
        'nameEn': 'Isha (Night)',
        'nameAr': 'العشاء',
        'time': 'Night',
        'timeAr': 'الليل',
        'rakaat': 4,
        'sunnahBefore': 0,
        'sunnahAfter': 2,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.isArabic ? 'ادعية واحاديث' : 'Supplications and Hadiths'),
        actions: const [LangToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.mosque,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.isArabic ? 'ادعية واحاديث' : 'Supplications and Hadiths',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.isArabic
                        ? 'مجموعة من الأدعية والأحاديث النبوية الشريفة'
                        : 'A collection of supplications and noble hadiths',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Content placeholder - can be replaced with actual supplications and hadiths
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.isArabic ? 'أدعية الشفاء' : 'Healing Supplications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.isArabic
                        ? 'اللهم رب الناس، أذهب البأس، واشف أنت الشافي، لا شفاء إلا شفاؤك، شفاء لا يغادر سقماً'
                        : 'O Allah, Lord of the people, remove the affliction and cure. You are the Healer. There is no cure except Your cure, a cure that leaves no illness.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.isArabic ? 'حديث شريف' : 'Noble Hadith',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.isArabic
                        ? 'قال رسول الله صلى الله عليه وسلم: "ما من مسلم يصيبه أذى من مرض فما سواه إلا حط الله به سيئاته كما تحط الشجرة ورقها"'
                        : 'The Messenger of Allah (peace be upon him) said: "No Muslim is afflicted with any harm, whether from illness or otherwise, but Allah will expiate his sins because of it, as a tree sheds its leaves."',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Prayer Cards (keeping for reference but can be removed)
          ...prayers.map((prayer) {
            final name = loc.isArabic ? prayer['nameAr'] : prayer['nameEn'];
            final time = loc.isArabic ? prayer['timeAr'] : prayer['time'];
            final rakaat = prayer['rakaat'] as int;
            final sunnahBefore = prayer['sunnahBefore'] as int;
            final sunnahAfter = prayer['sunnahAfter'] as int;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prayer Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.mosque,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.toString(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Raka'at Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.isArabic ? 'عدد الركعات' : 'Raka\'at Count',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRakaatInfo(
                                  context,
                                  loc.isArabic ? 'الفرض' : 'Fard (Obligatory)',
                                  rakaat,
                                  theme,
                                ),
                              ),
                              if (sunnahBefore > 0 || sunnahAfter > 0) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildRakaatInfo(
                                    context,
                                    loc.isArabic ? 'السنة' : 'Sunnah',
                                    sunnahBefore + sunnahAfter,
                                    theme,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (sunnahBefore > 0 || sunnahAfter > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              loc.isArabic
                                  ? '${sunnahBefore > 0 ? "قبل: $sunnahBefore" : ""} ${sunnahAfter > 0 ? "بعد: $sunnahAfter" : ""}'
                                  : '${sunnahBefore > 0 ? "Before: $sunnahBefore" : ""} ${sunnahAfter > 0 ? "After: $sunnahAfter" : ""}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Additional Information Card
          Card(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.isArabic ? 'معلومات إضافية' : 'Additional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.isArabic
                        ? '• يمكن أداء الصلاة في المستشفى أو المنزل\n• يمكن الجمع بين الصلوات في حالة الضرورة\n• يمكن القصر (تقصير الصلاة) للمسافرين\n• استشر إمام المسجد للحصول على التوجيه'
                        : '• Prayers can be performed at the hospital or home\n• Prayers can be combined in case of necessity\n• Prayer can be shortened (Qasr) for travelers\n• Consult with mosque imam for guidance',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRakaatInfo(
    BuildContext context,
    String label,
    int count,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            'Raka\'at',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

