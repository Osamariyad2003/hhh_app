import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class SpiritualNeedsScreen extends StatelessWidget {
  const SpiritualNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Supplications (ادعية)
    final supplications = [
      {
        'titleAr': 'دعاء الشفاء',
        'titleEn': 'Healing Supplication',
        'textAr': 'اللهم رب الناس، أذهب البأس، واشف أنت الشافي، لا شفاء إلا شفاؤك، شفاء لا يغادر سقماً',
        'textEn': 'O Allah, Lord of the people, remove the affliction and cure. You are the Healer. There is no cure except Your cure, a cure that leaves no illness.',
      },
      {
        'titleAr': 'دعاء عند المرض',
        'titleEn': 'Supplication During Illness',
        'textAr': 'اللهم عافني في بدني، اللهم عافني في سمعي، اللهم عافني في بصري، لا إله إلا أنت',
        'textEn': 'O Allah, grant me health in my body. O Allah, grant me health in my hearing. O Allah, grant me health in my sight. There is no god but You.',
      },
      {
        'titleAr': 'دعاء الرزق والصحة',
        'titleEn': 'Supplication for Provision and Health',
        'textAr': 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة، اللهم إني أسألك العفو والعافية في ديني ودنياي وأهلي ومالي',
        'textEn': 'O Allah, I ask You for pardon and well-being in this life and the next. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth.',
      },
      {
        'titleAr': 'دعاء الهم والحزن',
        'titleEn': 'Supplication for Worry and Grief',
        'textAr': 'اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والجبن والبخل، وغلبة الدين وقهر الرجال',
        'textEn': 'O Allah, I seek refuge in You from worry and grief, from incapacity and laziness, from cowardice and miserliness, from being overcome by debt and from being overpowered by men.',
      },
      {
        'titleAr': 'دعاء للمريض',
        'titleEn': 'Supplication for the Sick',
        'textAr': 'اللهم اشف عبدك ينفعنا به، اللهم اشف عبدك ينفعنا به، اللهم اشف عبدك ينفعنا به',
        'textEn': 'O Allah, heal Your servant so that he may benefit us. O Allah, heal Your servant so that he may benefit us. O Allah, heal Your servant so that he may benefit us.',
      },
      {
        'titleAr': 'دعاء الصبر',
        'titleEn': 'Supplication for Patience',
        'textAr': 'اللهم إني أسألك الصبر عند المصيبة، والشكر عند الرخاء، والرضا بقضائك',
        'textEn': 'O Allah, I ask You for patience in times of calamity, gratitude in times of ease, and contentment with Your decree.',
      },
      {
        'titleAr': 'دعاء للأطفال',
        'titleEn': 'Supplication for Children',
        'textAr': 'اللهم بارك لي في أولادي ووفقهم لطاعتك وارزقني برهم',
        'textEn': 'O Allah, bless me in my children and grant them success in obeying You, and grant me their righteousness.',
      },
      {
        'titleAr': 'دعاء الحفظ',
        'titleEn': 'Supplication for Protection',
        'textAr': 'اللهم احفظني بالإسلام قائماً، واحفظني بالإسلام قاعداً، واحفظني بالإسلام راقداً، ولا تشمت بي عدواً ولا حاسداً',
        'textEn': 'O Allah, protect me with Islam while standing, protect me with Islam while sitting, protect me with Islam while lying down, and do not let any enemy or envious person rejoice over me.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.isArabic ? 'ادعية' : 'Supplications'),
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
                    loc.isArabic ? 'ادعية' : 'Supplications',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.isArabic
                        ? 'مجموعة من الأدعية المباركة'
                        : 'A collection of blessed supplications',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Supplication Cards
          ...supplications.map((supplication) {
            final title = loc.isArabic ? supplication['titleAr'] : supplication['titleEn'];
            final text = loc.isArabic ? supplication['textAr'] : supplication['textEn'];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplication Title
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
                          child: Text(
                            title.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Supplication Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        text.toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          fontSize: loc.isArabic ? 18 : 16,
                        ),
                        textAlign: loc.isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
