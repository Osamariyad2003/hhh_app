import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../services/track_service.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/child_tracking_map.dart';

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

String _formatDob(dynamic dob) {
  if (dob is String) {
    try {
      final dt = DateTime.parse(dob);
      return DateFormat('dd MMM yyyy').format(dt);
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
  if (d == null) return '';

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
  const TrackDashboardScreen({super.key});

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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('trackYourChild')),
        actions: [
          IconButton(
            tooltip: loc.t('manageChildren'),
            icon: const Icon(Icons.people_alt),
            onPressed: () => context.push('/track/manage'),
          ),
          const LangToggleButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/track/add-child'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: TrackService.instance.childrenStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Unable to load children',
              message: 'Please check your connection and try again.',
            );
          }
          if (!snapshot.hasData) {
            return const EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Loading children...',
              isLoading: true,
            );
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

          final childDoc = _pickChildDoc(docs, _selectedChildId);
          _selectedChildId = childDoc['id'] ?? childDoc['_id'];

          final childData = childDoc;
          final dob = childData['dob'];
          final dobText = _formatDob(dob);
          final ageText = _ageFromDob(dob);

          final rawSex = (childData['sex'] ?? '').toString().trim();
          final sex = (rawSex.isEmpty || rawSex == 'unspecified') ? '' : rawSex;

          final notes = (childData['notes'] ?? '').toString().trim();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedChildId,
                        decoration: InputDecoration(
                          labelText: loc.t('selectChild'),
                        ),
                        items: docs.map((d) {
                          final id = d['id'] ?? d['_id'];
                          final name = d['name'] ?? '';
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedChildId = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (dobText.isNotEmpty || ageText.isNotEmpty || sex.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      [
                        if (dobText.isNotEmpty) '${loc.t('dob')}: $dobText',
                        if (ageText.isNotEmpty) '${loc.t('age')}: $ageText',
                        if (sex.isNotEmpty) 'Sex: $sex',
                      ].join('   •   '),
                    ),
                  ),
                ),
              if (notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      notes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

// Helper function to get child ID from map
String? _getChildId(Map<String, dynamic> child) {
  return child['id'] ?? child['_id'];
}

// Helper to build child dropdown (if you still need a separate builder)
Widget _buildChildDropdown(
  BuildContext context,
  List<Map<String, dynamic>> docs,
  String? selectedId,
  ValueChanged<String?> onChanged,
) {
  return DropdownButtonFormField<String>(
    value: selectedId,
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context).t('selectChild'),
    ),
    items: docs.map((d) {
      final id = _getChildId(d);
      final name = d['name'] ?? '';
      return DropdownMenuItem<String>(value: id, child: Text(name));
    }).toList(),
    onChanged: onChanged,
  );
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
                  latitude: 24.7136, // Default to Riyadh, can be updated with actual location
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
                value: clothes,
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
                value: clothes,
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

    return StreamBuilder(
      stream: TrackService.instance.weightsStream(
        childId,
        descending: false,
        limit: 200,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Unable to load weight data',
            message: 'Please try again later.',
          );
        }
        if (!snapshot.hasData) {
          return const EmptyStateWidget(
            icon: Icons.monitor_weight_outlined,
            title: 'Loading weight data...',
            isLoading: true,
          );
        }

        final ascDocs = snapshot.data!;
        if (ascDocs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.monitor_weight_outlined,
            title: 'No weight logs yet',
            message: 'Start tracking your child\'s weight to see data here.',
            actionLabel: 'Add Weight',
            onAction: () => _add(context),
          );
        }

        // Get last 7 entries for graph
        final last7Docs = ascDocs.length > 7 ? ascDocs.sublist(ascDocs.length - 7) : ascDocs;
        final spots = <FlSpot>[];
        for (final d in last7Docs) {
          final ts = d['ts'];
          final kg = d['valueKg'];
          if (ts is String && kg is num) {
            try {
              final dt = DateTime.parse(ts);
              spots.add(
                FlSpot(dt.millisecondsSinceEpoch.toDouble(), kg.toDouble()),
              );
            } catch (e) {
              // Skip invalid timestamps
            }
          }
        }

        final descDocs = ascDocs.reversed.toList();

        return Column(
          children: [
            // Trends section
            if (spots.length >= 2)
              Card(
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
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minX: spots.first.x,
                            maxX: spots.last.x,
                            minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5,
                            maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 10,
                            ),
                            borderData: FlBorderData(show: true),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: 10,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 34,
                                  interval: ((spots.last.x - spots.first.x) / 3).clamp(1, double.infinity),
                                  getTitlesWidget: (value, meta) {
                                    final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        DateFormat('MM/dd').format(dt),
                                        style: const TextStyle(fontSize: 11),
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
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) =>
                                      FlDotCirclePainter(radius: 4, color: Colors.red),
                                ),
                                color: Colors.red,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.red.withValues(alpha: 0.1),
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
            // History section
            Padding(
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
            const SizedBox(height: 8),
            // History list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: descDocs.length,
                itemBuilder: (context, i) {
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
                            // Three dots menu
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
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Weight value
                                  Text(
                                    'kg $kgValue',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Date/time
                                  Text(
                                    whenText,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Small icon
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
              ),
            ),
            // Add Weight button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _add(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.t('addWeight'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                value: method,
                decoration: const InputDecoration(
                  labelText: 'Method (optional)',
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
                value: method,
                decoration: const InputDecoration(
                  labelText: 'Method (optional)',
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
                title: 'Unable to load feeding data',
                message: 'Please try again later.',
              );
            }
            if (!snapshot.hasData) {
              return const EmptyStateWidget(
                icon: Icons.restaurant_outlined,
                title: 'Loading feeding data...',
                isLoading: true,
              );
            }

            final docs = snapshot.data!;
            if (docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.restaurant_outlined,
                title: 'No feeding logs yet',
                message: 'Start tracking your child\'s feedings to see data here.',
                actionLabel: 'Add Feeding',
                onAction: () => _add(context),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i];
                final logId = d['id'] ?? d['_id'] ?? '';
                final ml = d['amountMl'] as num?;
                final mlValue = ml?.toInt() ?? 0;
                final type = (d['type'] ?? '').toString();
                final method = (d['method'] ?? 'bottle').toString();
                final whenText = _formatTs(d['ts']);
                final bottleText = loc.isArabic ? 'زجاجة' : loc.t('bottle');

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.grey.shade100,
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
                          // Three dots menu
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
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ml - bottle format
                                Text(
                                  loc.isArabic 
                                    ? 'ml $mlValue - $bottleText'
                                    : 'ml $mlValue - $bottleText',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Date/time
                                Text(
                                  whenText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Fork/knife icon
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
            );
          },
        ),
        // FAB in bottom-left
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
                title: 'Unable to load oxygen data',
                message: 'Please try again later.',
              );
            }
            if (!snapshot.hasData) {
              return const EmptyStateWidget(
                icon: Icons.air_outlined,
                title: 'Loading oxygen data...',
                isLoading: true,
              );
            }

            final docs = snapshot.data!;
            if (docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.air_outlined,
                title: 'No oxygen logs yet',
                message: 'Start tracking your child\'s oxygen levels to see data here.',
                actionLabel: 'Add Oxygen Reading',
                onAction: () => _add(context),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i];
                final logId = d['id'] ?? d['_id'] ?? '';
                final v = d['spo2'] as num?;
                final spo2Value = v?.toInt() ?? 0;
                final whenText = _formatTs(d['ts']);
                final isLow = spo2Value < 90;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
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
                          // Three dots menu
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
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Percentage value
                                Text(
                                  '$spo2Value%',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Date/time
                                Text(
                                  whenText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Low saturation warning
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
                          // Heart icon
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
            );
          },
        ),
        // FAB in bottom-left
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

class LineChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  const LineChartCard({required this.spots, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minX = spots.first.x;
    final maxX = spots.last.x;

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: ((maxX - minX) / 3).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd/MM').format(dt),
                            style: const TextStyle(fontSize: 11),
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
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// exactly as you had them; they compile as-is once the helpers above are fixed.
