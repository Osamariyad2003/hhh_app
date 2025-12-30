import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../services/track_service.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/child_tracking_map.dart';
import '../core/app_theme.dart';

String _formatTs(dynamic ts) {
  if (ts is String) {
    try {
      final dt = DateTime.parse(ts);
      return DateFormat('MMM dd, yyyy - HH:mm').format(dt);
    } catch (e) {
      return '';
    }
  }
  return '';
}

String _formatTsShort(dynamic ts) {
  if (ts is String) {
    try {
      final dt = DateTime.parse(ts);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }
  return '';
}



String _ageFromDob(dynamic dob) {
  DateTime? d;
  if (dob is String) {
    try {
      d = DateTime.parse(dob);
    } catch (e) {
      return '';
    }
  } else {
    return '';
  }

  final now = DateTime.now();

  int months = (now.year - d.year) * 12 + (now.month - d.month);
  if (now.day < d.day) months -= 1;
  if (months < 0) months = 0;

  final years = months ~/ 12;
  final remMonths = months % 12;

  if (years == 0) return '$months month${months == 1 ? '' : 's'}';
  if (remMonths == 0) return '$years year${years == 1 ? '' : 's'}';
  return '$years year${years == 1 ? '' : 's'}, $remMonths month${remMonths == 1 ? '' : 's'}';
}

Future<bool?> _confirmDeleteDialog(
  BuildContext context,
  String title,
  String body,
  String cancel,
  String delete,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(delete),
        ),
      ],
    ),
  );
}

class TrackDashboardScreen extends StatefulWidget {
  final String? initialChildId;
  const TrackDashboardScreen({this.initialChildId, super.key});

  @override
  State<TrackDashboardScreen> createState() => _TrackDashboardScreenState();
}

class _TrackDashboardScreenState extends State<TrackDashboardScreen> {
  String? _selectedChildId;

  Map<String, dynamic> _pickChildDoc(
    List<Map<String, dynamic>> docs,
    String? selectedId,
  ) {
    if (docs.isEmpty) {
      throw StateError('No children documents available');
    }

    final wanted = selectedId ?? docs.first['id'] ?? docs.first['_id'];

    for (final d in docs) {
      final id = d['id'] ?? d['_id'];
      if (id == wanted) return d;
    }

    return docs.first;
  }

  bool _isArchived(Map<String, dynamic> data) {
    final v = data['archived'];
    return v is bool ? v : false;
  }

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.initialChildId;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('trackYourChild')),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: loc.t('manageChildren'),
            icon: const Icon(Icons.people_outlined),
            onPressed: () => context.push('/track/manage'),
          ),
          const LangToggleButton(),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: TrackService.instance.childrenStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: loc.t('unableToLoadChildren'),
              message: loc.t('checkConnection'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!;
          final docs = allDocs.where((d) => !_isArchived(d)).toList();

          if (docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.child_care_outlined,
              title: loc.t('noActiveChildren'),
              message: loc.t('addChildToStart'),
              actionLabel: loc.t('addChild'),
              onAction: () => context.push('/track/add-child'),
            );
          }

          final firstId = docs.first['id'] ?? docs.first['_id'];
          _selectedChildId ??= firstId;

          if (!docs.any((d) => (d['id'] ?? d['_id']) == _selectedChildId)) {
             _selectedChildId = firstId;
          }

          final childDoc = _pickChildDoc(docs, _selectedChildId);
          _selectedChildId = childDoc['id'] ?? childDoc['_id'];

          final childData = childDoc;
          final dob = childData['dob'];
          final ageText = _ageFromDob(dob);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == docs.length) {
                      return GestureDetector(
                        onTap: () => context.push('/track/add-child'),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.t('addChild'),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final d = docs[index];
                    final id = d['id'] ?? d['_id'];
                    final name = d['name'] ?? '';
                    final isSelected = id == _selectedChildId;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedChildId = id),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: isSelected 
                                    ? theme.colorScheme.primaryContainer 
                                    : theme.colorScheme.secondaryContainer,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          childData['name'] ?? '',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ageText.isNotEmpty)
                          Text(
                            ageText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/track/child/$_selectedChildId'),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: Text(loc.t('openDetails')),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: _ChildTabs(childId: _selectedChildId!)),
            ],
          );
        },
      ),
    );
  }
}

String? _getChildId(Map<String, dynamic> child) {
  return child['id'] ?? child['_id'];
}


class _ChildTabs extends StatelessWidget {
  final String childId;
  const _ChildTabs({required this.childId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: loc.t('weight')),
              Tab(text: loc.t('feeding')),
              Tab(text: loc.t('oxygen')),
              Tab(text: loc.t('map')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                WeightsTab(childId: childId),
                FeedingsTab(childId: childId),
                OxygenTab(childId: childId),
                const ChildTrackingMap(
                  latitude: 24.7136, 
                  longitude: 46.6753,
                  locationName: 'Child Location',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class WeightsTab extends StatelessWidget {
  final String childId;
  const WeightsTab({required this.childId, super.key});

  Future<void> _add(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final value = TextEditingController();
    final note = TextEditingController();
    String clothes = 'none';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(loc.t('addWeightKg')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: loc.t('kg')),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: loc.t('noteOptional')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: clothes,
                decoration: const InputDecoration(
                  labelText: 'Clothes (optional)',
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not set')),
                  DropdownMenuItem(
                    value: 'with_diaper',
                    child: Text('With diaper'),
                  ),
                  DropdownMenuItem(
                    value: 'no_clothes',
                    child: Text('No clothes'),
                  ),
                ],
                onChanged: (v) => setState(() => clothes = v ?? 'none'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final kg = double.tryParse(value.text.trim());
      if (kg != null) {
        await TrackService.instance.addWeight(
          childId: childId,
          valueKg: kg,
          note: note.text,
          unit: 'kg',
          clothes: clothes == 'none' ? null : clothes,
          source: 'manual',
        );
      }
    }

    value.dispose();
    note.dispose();
  }

  Future<void> _edit(
    BuildContext context,
    String logId,
    String currentKg,
    String currentNote,
    String currentClothes,
  ) async {
    final loc = AppLocalizations.of(context);
    final value = TextEditingController(text: currentKg);
    final note = TextEditingController(text: currentNote);
    String clothes = currentClothes.trim().isEmpty ? 'none' : currentClothes;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(loc.t('editWeight')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: loc.t('kg')),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: loc.t('noteOptional')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: clothes,
                decoration: const InputDecoration(
                  labelText: 'Clothes (optional)',
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not set')),
                  DropdownMenuItem(
                    value: 'with_diaper',
                    child: Text('With diaper'),
                  ),
                  DropdownMenuItem(
                    value: 'no_clothes',
                    child: Text('No clothes'),
                  ),
                ],
                onChanged: (v) => setState(() => clothes = v ?? 'none'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final kg = double.tryParse(value.text.trim());
      if (kg != null) {
        await TrackService.instance.updateWeight(
          childId: childId,
          logId: logId,
          valueKg: kg,
          note: note.text,
          unit: 'kg',
          clothes: clothes == 'none' ? null : clothes,
        );
      }
    }

    value.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Stack(
      children: [
        StreamBuilder(
          stream: TrackService.instance.weightsStream(
            childId,
            descending: false,
            limit: 200,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadWeightData'),
                message: loc.t('pleaseTryAgainLater'),
              );
            }
            if (!snapshot.hasData) {
              return EmptyStateWidget(
                icon: Icons.monitor_weight_outlined,
                title: loc.t('loadingWeightData'),
                isLoading: true,
              );
            }

            final ascDocs = snapshot.data!;
            if (ascDocs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.monitor_weight_outlined,
                title: loc.t('noWeightLogs'),
                message: loc.t('startTrackingWeight'),
                actionLabel: loc.t('addWeightAction'),
                onAction: () => _add(context),
              );
            }

            final last7Docs = ascDocs.length > 7 ? ascDocs.sublist(ascDocs.length - 7) : ascDocs;
            final spots = <FlSpot>[];

            for (final d in last7Docs) {
              final ts = d['ts'];
              final rawKg = d['valueKg'];

              double? kg;
              if (rawKg is num) {
                kg = rawKg.toDouble();
              } else if (rawKg is String) {
                kg = double.tryParse(rawKg);
              }

              if (kg != null) {
                try {
                  DateTime? dt;
                  if (ts is Timestamp) {
                    dt = ts.toDate();
                  } else if (ts is String) {
                    dt = DateTime.tryParse(ts);
                  }

                  if (dt != null) {
                    spots.add(
                      FlSpot(dt.millisecondsSinceEpoch.toDouble(), kg),
                    );
                  }
                } catch (e) {
                }
              }
            }
            spots.sort((a, b) => a.x.compareTo(b.x));

            final descDocs = ascDocs.reversed.toList();

            double minX = 0;
            double maxX = 0;
            double minY = 0;
            double maxY = 10;
            if (spots.length >= 2) {
              minX = spots.first.x;
              final rawMaxX = spots.last.x;
              maxX = rawMaxX == minX ? minX + 86400000 : rawMaxX;
              
              final yValues = spots.map((s) => s.y);
              minY = yValues.reduce((a, b) => a < b ? a : b);
              maxY = yValues.reduce((a, b) => a > b ? a : b);
              
              if (minY == maxY) {
                 minY -= 5;
                 maxY += 5;
              } else {
                 minY -= 2;
                 maxY += 2;
              }
            }

            return CustomScrollView(
              slivers: [
                 if (spots.length < 2)
                  SliverToBoxAdapter(
                    child: Card(
                       margin: const EdgeInsets.all(16),
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Text('Debug: Not enough valid data points. Spots: ${spots.length}. Raw Docs: ${ascDocs.length}'),
                       ),
                    ),
                  ),

                if (spots.length >= 2)
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('trends'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('lastEntries'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.red),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  minX: minX,
                                  maxX: maxX,
                                  minY: minY,
                                  maxY: maxY,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: (maxY - minY) / 4,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: ((maxX - minX) / 3).clamp(1, double.infinity),
                                        getTitlesWidget: (value, meta) {
                                          final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              DateFormat('MM/dd').format(dt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      color: theme.colorScheme.tertiary,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: theme.colorScheme.surface,
                                            strokeWidth: 2,
                                            strokeColor: theme.colorScheme.tertiary,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.tertiary.withValues(alpha: 0.3),
                                            theme.colorScheme.tertiary.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // History Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.t('entries')} ${descDocs.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          loc.t('history'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80), 
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final d = descDocs[i];
                        final logId = d['id'] ?? d['_id'] ?? '';
                        final kg = d['valueKg'] as num?;
                        final kgValue = kg?.toStringAsFixed(1) ?? '0.0';
                        final whenText = _formatTsShort(d['ts']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _edit(
                              context,
                              logId,
                              kgValue,
                              (d['note'] ?? '').toString(),
                              (d['clothes'] ?? '').toString(),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _edit(
                                          context,
                                          logId,
                                          kgValue,
                                          (d['note'] ?? '').toString(),
                                          (d['clothes'] ?? '').toString(),
                                        );
                                      } else if (value == 'delete') {
                                        _confirmDeleteDialog(
                                          context,
                                          loc.t('deleteLogTitle'),
                                          loc.t('deleteLogBody'),
                                          loc.t('cancel'),
                                          loc.t('delete'),
                                        ).then((confirmed) {
                                          if (confirmed == true) {
                                            TrackService.instance.deleteWeight(
                                              childId: childId,
                                              logId: logId,
                                            );
                                          }
                                        });
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(value: 'edit', child: Text(loc.t('edit'))),
                                      PopupMenuItem(value: 'delete', child: Text(loc.t('delete'))),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'kg $kgValue',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          whenText,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: descDocs.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'addWeightFab',
            backgroundColor: Colors.red.shade100,
            onPressed: () => _add(context),
            child: const Icon(Icons.add, color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class FeedingsTab extends StatelessWidget {
  final String childId;
  const FeedingsTab({required this.childId, super.key});

  Future<void> _add(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final amount = TextEditingController();
    final type = TextEditingController(text: 'Bottle');
    final note = TextEditingController();
    String method = 'none';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(loc.t('addFeeding')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: loc.t('amountMl')),
              ),
              TextField(
                controller: type,
                decoration: InputDecoration(labelText: loc.t('type')),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: loc.t('noteOptional')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: InputDecoration(
                  labelText: loc.t('methodOptional'),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not set')),
                  DropdownMenuItem(value: 'bottle', child: Text('Bottle')),
                  DropdownMenuItem(value: 'breast', child: Text('Breast')),
                  DropdownMenuItem(value: 'tube', child: Text('Tube')),
                ],
                onChanged: (v) => setState(() => method = v ?? 'none'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final ml = double.tryParse(amount.text.trim());
      if (ml != null) {
        await TrackService.instance.addFeeding(
          childId: childId,
          amountMl: ml,
          type: type.text,
          note: note.text,
          unit: 'ml',
          method: method == 'none' ? null : method,
          source: 'manual',
        );
      }
    }

    amount.dispose();
    type.dispose();
    note.dispose();
  }

  Future<void> _edit(
    BuildContext context,
    String logId,
    String currentMl,
    String currentType,
    String currentNote,
    String currentMethod,
  ) async {
    final loc = AppLocalizations.of(context);
    final amount = TextEditingController(text: currentMl);
    final type = TextEditingController(text: currentType);
    final note = TextEditingController(text: currentNote);
    String method = currentMethod.trim().isEmpty ? 'none' : currentMethod;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(loc.t('editFeeding')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: loc.t('amountMl')),
              ),
              TextField(
                controller: type,
                decoration: InputDecoration(labelText: loc.t('type')),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: loc.t('noteOptional')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: InputDecoration(
                  labelText: loc.t('methodOptional'),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not set')),
                  DropdownMenuItem(value: 'bottle', child: Text('Bottle')),
                  DropdownMenuItem(value: 'breast', child: Text('Breast')),
                  DropdownMenuItem(value: 'tube', child: Text('Tube')),
                ],
                onChanged: (v) => setState(() => method = v ?? 'none'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final ml = double.tryParse(amount.text.trim());
      if (ml != null) {
        await TrackService.instance.updateFeeding(
          childId: childId,
          logId: logId,
          amountMl: ml,
          type: type.text,
          note: note.text,
          unit: 'ml',
          method: method == 'none' ? null : method,
        );
      }
    }

    amount.dispose();
    type.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Stack(
      children: [
        StreamBuilder(
          stream: TrackService.instance.feedingsStream(
            childId,
            descending: true,
            limit: 200,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadFeedingData'),
                message: loc.t('pleaseTryAgainLater'),
              );
            }
            if (!snapshot.hasData) {
              return EmptyStateWidget(
                icon: Icons.restaurant_outlined,
                title: loc.t('loadingFeedingData'),
                isLoading: true,
              );
            }

            final docs = snapshot.data!;
            if (docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.restaurant_outlined,
                title: loc.t('noFeedingLogs'),
                message: loc.t('startTrackingFeeding'),
                actionLabel: loc.t('addFeedingAction'),
                onAction: () => _add(context),
              );
            }

            final ascDocs = docs.reversed.toList();
            final last7Docs = ascDocs.length > 7 ? ascDocs.sublist(ascDocs.length - 7) : ascDocs;
            final spots = <FlSpot>[];
            for (final d in last7Docs) {
              final ts = d['ts'];
              final rawMl = d['amountMl'];

              double? ml;
              if (rawMl is num) {
                ml = rawMl.toDouble();
              } else if (rawMl is String) {
                ml = double.tryParse(rawMl);
              }

              if (ml != null) {
                try {
                  DateTime? dt;
                  if (ts is Timestamp) {
                    dt = ts.toDate();
                  } else if (ts is String) {
                    dt = DateTime.tryParse(ts);
                  }

                  if (dt != null) {
                    spots.add(
                      FlSpot(dt.millisecondsSinceEpoch.toDouble(), ml),
                    );
                  }
                } catch (e) {
                }
              }
            }
            spots.sort((a, b) => a.x.compareTo(b.x));

            double minX = 0;
            double maxX = 0;
            if (spots.length >= 2) {
              minX = spots.first.x;
              final rawMaxX = spots.last.x;
              maxX = rawMaxX == minX ? minX + 86400000 : rawMaxX;
            }

            return CustomScrollView(
              slivers: [
                if (spots.length >= 2)
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('trends'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('lastEntries'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Icon(Icons.arrow_drop_down, color: AppTheme.chartLineColor2),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  minX: minX,
                                  maxX: maxX,
                                  minY: 0,
                                  maxY: (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2).roundToDouble(),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 20,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: ((maxX - minX) / 3).clamp(1, double.infinity),
                                        getTitlesWidget: (value, meta) {
                                          final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              DateFormat('MM/dd').format(dt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      color: AppTheme.chartLineColor2, 
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: theme.colorScheme.surface,
                                            strokeWidth: 2,
                                            strokeColor: AppTheme.chartLineColor2,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.chartLineColor2.withValues(alpha: 0.3),
                                            AppTheme.chartLineColor2.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.t('entries')} ${docs.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          loc.t('history'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final d = docs[i];
                        final logId = d['id'] ?? d['_id'] ?? '';
                        final ml = d['amountMl'] as num?;
                        final mlValue = ml?.toInt() ?? 0;
                        final type = (d['type'] ?? '').toString();
                        final method = (d['method'] ?? 'bottle').toString();
                        final whenText = _formatTs(d['ts']);
                        final bottleText = loc.isArabic ? 'زجاجة' : loc.t('bottle');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.grey.shade50,
                          child: InkWell(
                            onTap: () => _edit(
                              context,
                              logId,
                              mlValue.toString(),
                              type,
                              (d['note'] ?? '').toString(),
                              method,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _edit(
                                          context,
                                          logId,
                                          mlValue.toString(),
                                          type,
                                          (d['note'] ?? '').toString(),
                                          method,
                                        );
                                      } else if (value == 'delete') {
                                        _confirmDeleteDialog(
                                          context,
                                          loc.t('deleteLogTitle'),
                                          loc.t('deleteLogBody'),
                                          loc.t('cancel'),
                                          loc.t('delete'),
                                        ).then((confirmed) {
                                          if (confirmed == true) {
                                            TrackService.instance.deleteFeeding(
                                              childId: childId,
                                              logId: logId,
                                            );
                                          }
                                        });
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(value: 'edit', child: Text(loc.t('edit'))),
                                      PopupMenuItem(value: 'delete', child: Text(loc.t('delete'))),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.isArabic 
                                            ? 'ml $mlValue - $bottleText'
                                            : 'ml $mlValue - $bottleText',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          whenText,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.pink.shade100,
            onPressed: () => _add(context),
            child: const Icon(Icons.add, color: Colors.pink),
          ),
        ),
      ],
    );
  }
}

class OxygenTab extends StatelessWidget {
  final String childId;
  const OxygenTab({required this.childId, super.key});

  Future<void> _add(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final spo2 = TextEditingController();
    final pulse = TextEditingController();
    final device = TextEditingController();
    final note = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.t('addOxygen')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: spo2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: loc.t('spo2')),
            ),
            TextField(
              controller: pulse,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: loc.t('pulseOptional')),
            ),
            TextField(
              controller: device,
              decoration: InputDecoration(labelText: loc.t('deviceOptional')),
            ),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: loc.t('noteOptional')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.t('cancel'))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.t('save'))),
        ],
      ),
    );

    if (ok == true) {
      final v = int.tryParse(spo2.text.trim());
      if (v != null) {
        final p = int.tryParse(pulse.text.trim());
        final dev = device.text.trim();

        await TrackService.instance.addOxygen(
          childId: childId,
          spo2: v,
          note: note.text,
          pulse: p,
          device: dev.isEmpty ? null : dev,
          source: 'manual',
        );
      }
    }

    spo2.dispose();
    pulse.dispose();
    device.dispose();
    note.dispose();
  }

  Future<void> _edit(
      BuildContext context,
      String logId,
      String currentSpo2,
      String currentNote,
      String currentPulse,
      String currentDevice,
      ) async {
    final loc = AppLocalizations.of(context);
    final spo2 = TextEditingController(text: currentSpo2);
    final pulse = TextEditingController(text: currentPulse);
    final device = TextEditingController(text: currentDevice);
    final note = TextEditingController(text: currentNote);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.t('editOxygen')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: spo2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: loc.t('spo2')),
            ),
            TextField(
              controller: pulse,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pulse (optional)'),
            ),
            TextField(
              controller: device,
              decoration: const InputDecoration(labelText: 'Device (optional)'),
            ),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: loc.t('noteOptional')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.t('cancel'))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.t('save'))),
        ],
      ),
    );

    if (ok == true) {
      final v = int.tryParse(spo2.text.trim());
      if (v != null) {
        final p = int.tryParse(pulse.text.trim());
        final dev = device.text.trim();

        await TrackService.instance.updateOxygen(
          childId: childId,
          logId: logId,
          spo2: v,
          note: note.text,
          pulse: p,
          device: dev.isEmpty ? null : dev,
        );
      }
    }

    spo2.dispose();
    pulse.dispose();
    device.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Stack(
      children: [
        StreamBuilder(
          stream: TrackService.instance.oxygenStream(childId, descending: true, limit: 200),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: loc.t('unableToLoadOxygenData'),
                message: loc.t('pleaseTryAgainLater'),
              );
            }
            if (!snapshot.hasData) {
              return EmptyStateWidget(
                icon: Icons.air_outlined,
                title: loc.t('loadingOxygenData'),
                isLoading: true,
              );
            }


            final docs = snapshot.data!;
            if (docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.air_outlined,
                title: loc.t('noOxygenLogs'),
                message: loc.t('startTrackingOxygen'),
                actionLabel: loc.t('addOxygenAction'),
                onAction: () => _add(context),
              );
            }

            final ascDocs = docs.reversed.toList();
            final last7Docs = ascDocs.length > 7 ? ascDocs.sublist(ascDocs.length - 7) : ascDocs;
            final spots = <FlSpot>[];
            
            for (final d in last7Docs) {
              final ts = d['ts'];
              final rawSpo2 = d['spo2'];
              
              double? spo2;
              if (rawSpo2 is num) {
                spo2 = rawSpo2.toDouble();
              } else if (rawSpo2 is String) {
                spo2 = double.tryParse(rawSpo2);
              }
              
              if (spo2 != null) {
                try {
                  DateTime? dt;
                  if (ts is Timestamp) {
                    dt = ts.toDate();
                  } else if (ts is String) {
                    dt = DateTime.tryParse(ts);
                  }
                  
                  if (dt != null) {
                    spots.add(FlSpot(dt.millisecondsSinceEpoch.toDouble(), spo2));
                  }
                } catch (e) {
                }
              }
            }
            spots.sort((a, b) => a.x.compareTo(b.x));

            double minX = 0;
            double maxX = 0;
            double minY = 80; 
            double maxY = 100; 
            
            if (spots.length >= 2) {
              minX = spots.first.x;
              final rawMaxX = spots.last.x;
              maxX = rawMaxX == minX ? minX + 86400000 : rawMaxX;
              
              final yValues = spots.map((s) => s.y);
              final actualMinY = yValues.reduce((a, b) => a < b ? a : b);
              final actualMaxY = yValues.reduce((a, b) => a > b ? a : b);
              
              minY = (actualMinY - 5).clamp(0, 100);
              maxY = (actualMaxY + 5).clamp(0, 100);
            }

            return CustomScrollView(
              slivers: [
                if (spots.length >= 2)
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('trends'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.t('lastEntries'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Icon(Icons.arrow_drop_down, color: AppTheme.chartLineColor3),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: LineChart(
                                LineChartData(
                                  minX: minX,
                                  maxX: maxX,
                                  minY: minY,
                                  maxY: maxY,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 5,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: ((maxX - minX) / 3).clamp(1, double.infinity),
                                        getTitlesWidget: (value, meta) {
                                          final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              DateFormat('MM/dd').format(dt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      color: AppTheme.chartLineColor3, 
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: theme.colorScheme.surface,
                                            strokeWidth: 2,
                                            strokeColor: AppTheme.chartLineColor3,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.chartLineColor3.withValues(alpha: 0.3),
                                            AppTheme.chartLineColor3.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      loc.t('history'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final d = docs[i];
                      final logId = d['id'] ?? d['_id'] ?? '';
                      final v = d['spo2'] as num?;
                      final spo2Value = v?.toInt() ?? 0;
                      final whenText = _formatTs(d['ts']);
                      final isLow = spo2Value < 90;

                      return Card(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        color: Colors.red.shade50,
                        child: InkWell(
                          onTap: () => _edit(
                            context,
                            logId,
                            spo2Value.toString(),
                            (d['note'] ?? '').toString(),
                            (d['pulse'] ?? '').toString(),
                            (d['device'] ?? '').toString(),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _edit(
                                        context,
                                        logId,
                                        spo2Value.toString(),
                                        (d['note'] ?? '').toString(),
                                        (d['pulse'] ?? '').toString(),
                                        (d['device'] ?? '').toString(),
                                      );
                                    } else if (value == 'delete') {
                                      _confirmDeleteDialog(
                                        context,
                                        loc.t('deleteLogTitle'),
                                        loc.t('deleteLogBody'),
                                        loc.t('cancel'),
                                        loc.t('delete'),
                                      ).then((confirmed) {
                                        if (confirmed == true) {
                                          TrackService.instance.deleteOxygen(
                                            childId: childId,
                                            logId: logId,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(value: 'edit', child: Text(loc.t('edit'))),
                                    PopupMenuItem(value: 'delete', child: Text(loc.t('delete'))),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$spo2Value%',
                                        style: theme.textTheme.headlineLarge?.copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        whenText,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (isLow)
                                        Text(
                                          loc.t('lowSaturationLevel'),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.red.shade100,
            onPressed: () => _add(context),
            child: const Icon(Icons.add, color: Colors.red),
          ),
        ),
      ],
    );
  }
}