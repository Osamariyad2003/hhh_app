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
    return sectionId == 'spiritual';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Special sections with custom screens
    if (_isSpecialSection()) {
      if (sectionId == 'spiritual') {
        return const SpiritualNeedsScreen();
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
                title: 'Unable to load hospitals',
                message: 'Please check your connection and try again.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('hospitalInfo')),
                actions: const [LangToggleButton()],
              ),
              body: const EmptyStateWidget(
                icon: Icons.local_hospital_outlined,
                title: 'Loading hospitals...',
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
                title: 'No hospitals available',
                message: 'Hospital information will appear here once available.',
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
                                hospital['name'] ?? 'Hospital',
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
              body: const EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: 'Loading support groups...',
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
                title: 'Unable to load support groups',
                message: 'Error: ${snapshot.error.toString()}\n\nPlease check your connection and try again.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(loc.t('caregiverSupport')),
                actions: const [LangToggleButton()],
              ),
              body: const EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: 'Loading support groups...',
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
                title: 'No support groups available',
                message: 'Support group information will appear here once available.',
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
                                group['name'] ?? 'Support Group',
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (group['description'] != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            group['description'] ?? '',
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
                title: const Text('Patient Stories'),
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
                title: const Text('Patient Stories'),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Unable to load stories',
                message: 'Error: ${snapshot.error.toString()}\n\nPlease check your connection and try again.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Patient Stories'),
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
                title: const Text('Patient Stories'),
                actions: const [LangToggleButton()],
              ),
              body: EmptyStateWidget(
                icon: Icons.book_outlined,
                title: 'No stories available',
                message: 'Patient stories will appear here once they are published.',
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
                          story['title'] ?? 'Story',
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (story['author'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'By ${story['author']}',
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
              title: 'Unable to load content',
              message: 'Please check your connection and try again.',
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(sectionId),
              actions: const [LangToggleButton()],
            ),
            body: const EmptyStateWidget(
              icon: Icons.article_outlined,
              title: 'Loading content...',
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
              title: 'No content available',
              message: 'Content for this section is not available yet.',
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
                  title: 'No content available',
                  message: 'This section has no content yet.',
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
}
