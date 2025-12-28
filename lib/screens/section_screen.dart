import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';
import '../services/sections_service.dart';
import '../services/hospital_service.dart';
import '../services/support_group_service.dart';
import '../services/patient_story_service.dart';
import '../models/section_content.dart';
import 'spiritual_needs_screen.dart';

class SectionScreen extends StatelessWidget {
  final String sectionId;
  const SectionScreen({super.key, required this.sectionId});

  String _pickText(AppLocalizations loc, Map<String, dynamic> block, String keyBase) {
    final ar = block['${keyBase}_ar'];
    final en = block['${keyBase}_en'];
    final v = loc.isArabic ? ar : en;
    return (v ?? '').toString();
  }

  List<String> _pickItems(AppLocalizations loc, Map<String, dynamic> block) {
    final raw = loc.isArabic ? block['items_ar'] : block['items_en'];
    if (raw is List) {
      return raw.map((e) => (e ?? '').toString()).where((s) => s.trim().isNotEmpty).toList();
    }
    return const [];
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _renderBlock(BuildContext context, AppLocalizations loc, Map<String, dynamic> block) {
    final type = (block['type'] ?? '').toString().trim();

    switch (type) {
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        );

      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        );

      case 'p':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _pickText(loc, block, 'text'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6, // Better line height for readability
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        );

      case 'bullets':
      case 'ul':
        final items = _pickItems(loc, block);
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 12),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );

      case 'callout':
        final text = _pickText(loc, block, 'text');
        if (text.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'link':
        final label = _pickText(loc, block, 'label');
        final url = (block['url'] ?? '').toString().trim();
        if (url.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: InkWell(
              onTap: () => _openLink(url),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label.trim().isEmpty ? url : label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Check if this section should use Firebase services
  bool _shouldUseFirebase() {
    return sectionId == 'hospital' || 
           sectionId == 'support' || 
           sectionId == 'patient-stories';
  }

  /// Check if this is a special section with custom screen
  bool _isSpecialSection() {
    return sectionId == 'spiritual' || sectionId == 'about' || sectionId == 'contacts';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Special sections with custom screens
    if (_isSpecialSection()) {
      if (sectionId == 'spiritual') {
        return const SpiritualNeedsScreen();
      }
      if (sectionId == 'about') {
        return _buildAboutChdSection(context, loc);
      }
      if (sectionId == 'contacts') {
        return _buildContactsSection(context, loc);
      }
    }

    // Use Firebase services for specific sections
    if (_shouldUseFirebase()) {
      return _buildFirebaseSection(context, loc);
    }

    // Use regular sections service for other sections
    return _buildRegularSection(context, loc);
  }

  /// Build section using Firebase services
  Widget _buildFirebaseSection(BuildContext context, AppLocalizations loc) {
    if (sectionId == 'hospital') {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: HospitalService.instance.streamHospitals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('hospitalInfo')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadHospitals'),
                message: loc.t('checkConnection'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('hospitalInfo')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.local_hospital_outlined,
                title: loc.t('loadingHospitals'),
                isLoading: true,
              ),
            );
          }

          final hospitals = snapshot.data!;
          if (hospitals.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('hospitalInfo')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.local_hospital_outlined,
                title: loc.t('noHospitalsAvailable'),
                message: loc.t('hospitalInfoWillAppear'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.t('hospitalInfo')),
              actions: const [LangToggleButton()],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: hospitals.length,
              itemBuilder: (context, i) {
                final hospital = hospitals[i];
                final contact = hospital['contactInfo'] as Map<String, dynamic>? ?? {};
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_hospital,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hospital['name'] ?? loc.t('hospital'),
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (contact['address'] != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  contact['address'] ?? '',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (contact['phone'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  contact['phone'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (contact['email'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  contact['email'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    if (sectionId == 'support') {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupportGroupService.instance.streamSupportGroups().handleError((error) {
          // Return empty list on error to prevent stream from closing
          return <Map<String, dynamic>>[];
        }),
        builder: (context, snapshot) {
          // Check for connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('caregiverSupport')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: loc.t('loadingSupportGroups'),
                isLoading: true,
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('caregiverSupport')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadSupportGroups'),
                message: '${loc.t('error')}: ${snapshot.error.toString()}\n\n${loc.t('checkConnection')}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('caregiverSupport')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: loc.t('loadingSupportGroups'),
                isLoading: true,
              ),
            );
          }

          final groups = snapshot.data!;
          if (groups.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('caregiverSupport')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: loc.t('noSupportGroupsAvailable'),
                message: loc.t('supportGroupInfoWillAppear'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(loc.t('caregiverSupport')),
              actions: const [LangToggleButton()],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final group = groups[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                group['nameEn'] ?? group['name'] ?? loc.t('supportGroup'),
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if ((group['descriptionEn'] ?? group['description']) != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            group['descriptionEn'] ?? group['description'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (group['meetingSchedule'] != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  group['meetingSchedule'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (group['contactInfo'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.contact_phone,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  group['contactInfo'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    if (sectionId == 'patient-stories') {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: PatientStoryService.instance.streamPublishedStories().handleError((error) {
          // Return empty list on error to prevent stream from closing
          return <Map<String, dynamic>>[];
        }),
        builder: (context, snapshot) {
          // Check for connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('patientStories')),
                actions: const [LangToggleButton()],
              ),
              body: const EmptyStateWidget(
                icon: Icons.book_outlined,
                title: 'Loading stories...',
                isLoading: true,
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('patientStories')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadStories'),
                message: '${loc.t('error')}: ${snapshot.error.toString()}\n\n${loc.t('checkConnection')}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('patientStories')),
                actions: const [LangToggleButton()],
              ),
              body: const EmptyStateWidget(
                icon: Icons.book_outlined,
                title: 'Loading stories...',
                isLoading: true,
              ),
            );
          }

          final stories = snapshot.data!;
          if (stories.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('patientStories')),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.book_outlined,
                title: loc.t('noStoriesAvailable'),
                message: loc.t('storiesWillAppear'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Patient Stories'),
              actions: const [LangToggleButton()],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: stories.length,
              itemBuilder: (context, i) {
                final story = stories[i];
                final content = loc.isArabic 
                    ? (story['contentArabic'] ?? story['contentEnglish'] ?? '')
                    : (story['contentEnglish'] ?? '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (story['imageUrl'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              story['imageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        if (story['imageUrl'] != null) const SizedBox(height: 16),
                        Text(
                          story['title'] ?? loc.t('story'),
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (story['author'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${loc.t('by')} ${story['author']}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                        if (content.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            content,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    // Fallback to regular section
    return _buildRegularSection(context, loc);
  }

  /// Build regular section using SectionsService
  Widget _buildRegularSection(BuildContext context, AppLocalizations loc) {
    return StreamBuilder<SectionContent?>(
      stream: SectionsService.instance.streamSection(sectionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadContent'),
                message: loc.t('checkConnection'),
              ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
              body: EmptyStateWidget(
                icon: Icons.article_outlined,
                title: loc.t('loadingContent'),
                isLoading: true,
              ),
          );
        }

        final section = snapshot.data;
        if (section == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
              body: EmptyStateWidget(
                icon: Icons.article_outlined,
                title: loc.t('noContentAvailable'),
                message: loc.t('contentNotAvailableYet'),
              ),
          );
        }

        final title = loc.isArabic ? section.titleAr : section.titleEn;
        final blocks = section.blocks.map((block) {
          return {
            'type': block.type,
            'text_en': block.textEn,
            'text_ar': block.textAr,
            'label_en': block.labelEn,
            'label_ar': block.labelAr,
            'url': block.url,
            'r2Key': block.r2Key,
            'items_en': null, // Add if needed
            'items_ar': null, // Add if needed
          };
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text((title == null || title.isEmpty) ? sectionId : title),
            actions: const [LangToggleButton()],
          ),
              body: blocks.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: loc.t('noContentAvailable'),
                  message: loc.t('sectionNoContent'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: blocks.length,
                  itemBuilder: (context, i) => _renderBlock(context, loc, blocks[i]),
                ),
        );
      },
    );
  }

  /// Build About CHD section with fixed content
  Widget _buildAboutChdSection(BuildContext context, AppLocalizations loc) {
    final content = loc.isArabic ? _aboutChdContentAr : _aboutChdContentEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('aboutChd')),
        actions: const [LangToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...content.map((block) => _renderBlock(context, loc, block)),
        ],
      ),
    );
  }

  /// Build Contacts section with fixed content
  Widget _buildContactsSection(BuildContext context, AppLocalizations loc) {
    final contacts = loc.isArabic ? _contactsContentAr : _contactsContentEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('contacts')),
        actions: const [LangToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...contacts.map((block) => _renderBlock(context, loc, block)),
        ],
      ),
    );
  }

  // Fixed content for About CHD (English)
  static const List<Map<String, dynamic>> _aboutChdContentEn = [
    {
      'type': 'h1',
      'text_en': 'About Congenital Heart Disease (CHD)',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'Congenital Heart Disease (CHD) refers to structural heart defects present at birth. These conditions affect the heart\'s structure and how blood flows through the heart and to the rest of the body.',
      'text_ar': '',
    },
    {
      'type': 'h2',
      'text_en': 'Types of CHD',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'CHD can range from simple defects that may not require treatment to complex conditions that need immediate medical intervention. Common types include:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Atrial Septal Defect (ASD) - Hole in the wall between the heart\'s upper chambers',
        'Ventricular Septal Defect (VSD) - Hole in the wall between the heart\'s lower chambers',
        'Tetralogy of Fallot - Combination of four heart defects',
        'Patent Ductus Arteriosus (PDA) - Abnormal connection between major blood vessels',
        'Coarctation of the Aorta - Narrowing of the aorta',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Causes and Risk Factors',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'The exact cause of CHD is often unknown, but several factors may increase the risk:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Genetic factors and family history',
        'Maternal health conditions (diabetes, rubella)',
        'Medications taken during pregnancy',
        'Environmental factors',
        'Chromosomal abnormalities',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Symptoms',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'Symptoms vary depending on the type and severity of the defect. Common signs include:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Rapid breathing or difficulty breathing',
        'Poor feeding and weight gain',
        'Bluish tint to skin, lips, and nails (cyanosis)',
        'Fatigue during feeding',
        'Swelling in legs, abdomen, or around eyes',
        'Heart murmur',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Treatment Options',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'Treatment depends on the type and severity of the defect. Options may include:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Medications to help the heart work more efficiently',
        'Catheter procedures to repair defects',
        'Open-heart surgery for complex defects',
        'Heart transplant in severe cases',
        'Lifelong monitoring and follow-up care',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Living with CHD',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'With proper treatment and care, many children with CHD can lead healthy, active lives. Regular medical follow-ups, a healthy lifestyle, and emotional support are essential for managing CHD effectively.',
      'text_ar': '',
    },
    {
      'type': 'callout',
      'text_en':
          'Important: Always consult with your child\'s healthcare provider for personalized medical advice and treatment plans.',
      'text_ar': '',
    },
  ];

  // Fixed content for About CHD (Arabic)
  static const List<Map<String, dynamic>> _aboutChdContentAr = [
    {
      'type': 'h1',
      'text_en': '',
      'text_ar': 'عن عيوب القلب الخلقية',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'عيوب القلب الخلقية (CHD) تشير إلى عيوب هيكلية في القلب موجودة عند الولادة. هذه الحالات تؤثر على بنية القلب وكيفية تدفق الدم عبر القلب وإلى باقي أجزاء الجسم.',
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'أنواع عيوب القلب الخلقية',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'يمكن أن تتراوح عيوب القلب الخلقية من عيوب بسيطة قد لا تحتاج إلى علاج إلى حالات معقدة تحتاج إلى تدخل طبي فوري. الأنواع الشائعة تشمل:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'عيب الحاجز الأذيني (ASD) - ثقب في الجدار بين الحجرات العلوية للقلب',
        'عيب الحاجز البطيني (VSD) - ثقب في الجدار بين الحجرات السفلية للقلب',
        'رباعية فالوت - مزيج من أربعة عيوب في القلب',
        'القناة الشريانية المفتوحة (PDA) - اتصال غير طبيعي بين الأوعية الدموية الرئيسية',
        'تضيق الأبهر - تضيق في الشريان الأورطي',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'الأسباب وعوامل الخطر',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'السبب الدقيق لعيوب القلب الخلقية غالباً ما يكون غير معروف، ولكن هناك عدة عوامل قد تزيد من المخاطر:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'العوامل الوراثية والتاريخ العائلي',
        'حالات صحية للأم (السكري، الحصبة الألمانية)',
        'الأدوية التي يتم تناولها أثناء الحمل',
        'العوامل البيئية',
        'الاضطرابات الكروموسومية',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'الأعراض',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'تختلف الأعراض حسب نوع وشدة العيب. العلامات الشائعة تشمل:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'التنفس السريع أو صعوبة التنفس',
        'ضعف التغذية وزيادة الوزن',
        'اللون الأزرق للجلد والشفتين والأظافر (الزرقة)',
        'التعب أثناء الرضاعة',
        'تورم في الساقين أو البطن أو حول العينين',
        'نفخة قلبية',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'خيارات العلاج',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'يعتمد العلاج على نوع وشدة العيب. الخيارات قد تشمل:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'الأدوية لمساعدة القلب على العمل بكفاءة أكبر',
        'إجراءات القسطرة لإصلاح العيوب',
        'جراحة القلب المفتوح للعيوب المعقدة',
        'زراعة القلب في الحالات الشديدة',
        'المراقبة مدى الحياة ورعاية المتابعة',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'العيش مع عيوب القلب الخلقية',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'مع العلاج والرعاية المناسبة، يمكن للعديد من الأطفال المصابين بعيوب القلب الخلقية أن يعيشوا حياة صحية ونشطة. المتابعة الطبية المنتظمة ونمط الحياة الصحي والدعم العاطفي ضرورية لإدارة عيوب القلب الخلقية بشكل فعال.',
    },
    {
      'type': 'callout',
      'text_en': '',
      'text_ar':
          'مهم: استشر دائماً مقدم الرعاية الصحية لطفلك للحصول على المشورة الطبية المخصصة وخطط العلاج.',
    },
  ];

  // Fixed content for Contacts (English)
  static const List<Map<String, dynamic>> _contactsContentEn = [
    {
      'type': 'h1',
      'text_en': 'Contact Information',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'For medical emergencies, please contact your local emergency services immediately.',
      'text_ar': '',
    },
    {
      'type': 'h2',
      'text_en': 'Emergency Contacts',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Emergency Services: 997 (Saudi Arabia)',
        'Ambulance: 997',
        'Police: 999',
        'Civil Defense: 998',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Medical Support',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'For non-emergency medical questions and support, please contact:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Your child\'s primary care physician',
        'Cardiology department at your local hospital',
        'Pediatric cardiology specialist',
      ],
      'items_ar': [],
    },
    {
      'type': 'h2',
      'text_en': 'Support Resources',
      'text_ar': '',
    },
    {
      'type': 'p',
      'text_en':
          'For additional support and resources, you can reach out to:',
      'text_ar': '',
    },
    {
      'type': 'ul',
      'items_en': [
        'Local support groups for families with CHD',
        'National heart associations',
        'Patient advocacy organizations',
      ],
      'items_ar': [],
    },
    {
      'type': 'callout',
      'text_en':
          'Note: Always keep your child\'s medical records and emergency contact information easily accessible.',
      'text_ar': '',
    },
  ];

  // Fixed content for Contacts (Arabic)
  static const List<Map<String, dynamic>> _contactsContentAr = [
    {
      'type': 'h1',
      'text_en': '',
      'text_ar': 'معلومات الاتصال',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'للطوارئ الطبية، يرجى الاتصال بخدمات الطوارئ المحلية على الفور.',
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'جهات الاتصال الطارئة',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'خدمات الطوارئ: 997 (المملكة العربية السعودية)',
        'الإسعاف: 997',
        'الشرطة: 999',
        'الدفاع المدني: 998',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'الدعم الطبي',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'للأسئلة الطبية غير الطارئة والدعم، يرجى الاتصال بـ:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'طبيب الرعاية الأولية لطفلك',
        'قسم أمراض القلب في المستشفى المحلي',
        'أخصائي أمراض قلب الأطفال',
      ],
    },
    {
      'type': 'h2',
      'text_en': '',
      'text_ar': 'موارد الدعم',
    },
    {
      'type': 'p',
      'text_en': '',
      'text_ar':
          'للحصول على دعم وموارد إضافية، يمكنك التواصل مع:',
    },
    {
      'type': 'ul',
      'items_en': [],
      'items_ar': [
        'مجموعات الدعم المحلية للأسر المصابة بعيوب القلب الخلقية',
        'جمعيات القلب الوطنية',
        'منظمات الدفاع عن المرضى',
      ],
    },
    {
      'type': 'callout',
      'text_en': '',
      'text_ar':
          'ملاحظة: احتفظ دائماً بسجلات طفلك الطبية ومعلومات الاتصال الطارئة في متناول اليد.',
    },
  ];
}
