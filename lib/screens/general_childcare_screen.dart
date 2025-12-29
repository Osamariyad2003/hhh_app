import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/general_childcare_cubit.dart';
import '../cubits/general_childcare_states.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';
import '../localization/app_localizations.dart';
import '../cubits/app_cubit.dart';
import 'childcare_detail_screen.dart';
import '../models/general_childcare_model.dart';

/// General Childcare Information Screen
/// Displays childcare information from Firestore collection 'general_childcare'
class GeneralChildcareScreen extends StatefulWidget {
  const GeneralChildcareScreen({super.key});

  @override
  State<GeneralChildcareScreen> createState() => _GeneralChildcareScreenState();
}

class _GeneralChildcareScreenState extends State<GeneralChildcareScreen> {
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'growth',
    'nutrition',
    'sleep',
    'hygiene',
    'safety',
    'daily_care',
    'development',
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final loc = AppLocalizations.of(context);
    final language = loc.isArabic ? 'ar' : 'en';
    context.read<GeneralChildcareCubit>().loadChildcareItems(
          language: language,
          category: _selectedCategory == 'all' ? null : _selectedCategory,
        );
  }

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
      case 'all':
        return loc.t('all');
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = loc.isArabic ? 'ar' : 'en';

    return BlocListener<AppCubit, AppState>(
      listener: (context, appState) {
        // Reload when language changes
        _loadData();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.t('generalChildcare')),
          actions: const [LangToggleButton()],
        ),
        body: Column(
          children: [
            // Category Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 16,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 6),
                            Text(_getCategoryName(category, loc)),
                          ],
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          context.read<GeneralChildcareCubit>().loadChildcareItems(
                                language: language,
                                category:
                                    category == 'all' ? null : category,
                              );
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: BlocBuilder<GeneralChildcareCubit, GeneralChildcareState>(
                builder: (context, state) {
                  if (state is GeneralChildcareLoading) {
                    return const EmptyStateWidget(
                      icon: Icons.child_care,
                      title: 'Loading childcare information...',
                      isLoading: true,
                    );
                  }

                  if (state is GeneralChildcareError) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: loc.t('unableToLoadChildcare'),
                      message: '${loc.t('error')}: ${state.message}\n\n${loc.t('checkConnection')}',
                      actionLabel: loc.t('retry'),
                      onAction: () => _loadData(),
                    );
                  }

                  if (state is GeneralChildcareSuccess) {
                    final items = state.items;

                    if (items.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.child_care,
                        title: loc.t('noChildcareAvailable'),
                        message: loc.t('childcareWillAppear'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildChildcareCard(context, item, loc);
                      },
                    );
                  }

                  return const EmptyStateWidget(
                    icon: Icons.child_care,
                    title: 'Loading childcare information...',
                    isLoading: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildcareCard(
      BuildContext context, GeneralChildcareModel item, AppLocalizations loc) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildcareDetailScreen(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Age Range (if available)
                    if (item.ageRange != null && item.ageRange!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.ageRange!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

