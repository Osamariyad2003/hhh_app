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
      return DateFormat('dd MMM yyyy • HH:mm').format(dt);
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
              title: 'No active children',
              message: 'Add a child to start tracking their health data, or unarchive one in Manage.',
              actionLabel: 'Add Child',
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
              const Tab(text: 'Map'),
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
          title: Text(loc.t('addWeight')),
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

            final spots = <FlSpot>[];
            for (final d in ascDocs) {
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
                if (spots.length >= 2) LineChartCard(spots: spots),
                Expanded(
                  child: ListView.separated(
                    itemCount: descDocs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = descDocs[i];
                      final logId = d['id'] ?? d['_id'] ?? '';

                      final kg = d['valueKg'];
                      final note = (d['note'] ?? '').toString();
                      final clothes = (d['clothes'] ?? '').toString();
                      final whenText = _formatTs(d['ts']);

                      final subtitleParts = <String>[whenText];
                      if (clothes.trim().isNotEmpty)
                        subtitleParts.add('Clothes: $clothes');
                      if (note.isNotEmpty) subtitleParts.add(note);

                      return Dismissible(
                        key: ValueKey(logId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDeleteDialog(
                          context,
                          loc.t('deleteLogTitle'),
                          loc.t('deleteLogBody'),
                          loc.t('cancel'),
                          loc.t('delete'),
                        ),
                        onDismissed: (_) => TrackService.instance.deleteWeight(
                          childId: childId,
                          logId: logId,
                        ),
                        child: ListTile(
                          title: Text('$kg ${loc.t('kg')}'),
                          subtitle: Text(subtitleParts.join('\n')),
                          isThreeLine: subtitleParts.length >= 3,
                          onTap: () => _edit(
                            context,
                            logId,
                            kg?.toString() ?? '',
                            note,
                            clothes,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _add(context),
            child: const Icon(Icons.add),
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

            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = docs[i];
                final logId = d['id'] ?? d['_id'] ?? '';

                final ml = d['amountMl'];
                final type = (d['type'] ?? '').toString();
                final note = (d['note'] ?? '').toString();
                final method = (d['method'] ?? '').toString();
                final whenText = _formatTs(d['ts']);

                final subtitleParts = <String>[whenText];
                if (method.trim().isNotEmpty)
                  subtitleParts.add('Method: $method');
                if (note.isNotEmpty) subtitleParts.add(note);

                return Dismissible(
                  key: ValueKey(logId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDeleteDialog(
                    context,
                    loc.t('deleteLogTitle'),
                    loc.t('deleteLogBody'),
                    loc.t('cancel'),
                    loc.t('delete'),
                  ),
                  onDismissed: (_) => TrackService.instance.deleteFeeding(
                    childId: childId,
                    logId: logId,
                  ),
                  child: ListTile(
                    title: Text('$ml ml • $type'),
                    subtitle: Text(subtitleParts.join('\n')),
                    isThreeLine: subtitleParts.length >= 3,
                    onTap: () => _edit(
                      context,
                      logId,
                      ml?.toString() ?? '',
                      type,
                      note,
                      method,
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _add(context),
            child: const Icon(Icons.add),
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

    return Stack(
      children: [
        StreamBuilder(
          stream: TrackService.instance.oxygenStream(childId, descending: false, limit: 200),
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

            final ascDocs = snapshot.data!;
            if (ascDocs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.air_outlined,
                title: 'No oxygen logs yet',
                message: 'Start tracking your child\'s oxygen levels to see data here.',
                actionLabel: 'Add Oxygen Reading',
                onAction: () => _add(context),
              );
            }

            final spots = <FlSpot>[];
            for (final d in ascDocs) {
              final ts = d['ts'];
              final v = d['spo2'];
              if (ts is String && v is num) {
                try {
                  final dt = DateTime.parse(ts);
                  spots.add(FlSpot(dt.millisecondsSinceEpoch.toDouble(), v.toDouble()));
                } catch (e) {
                  // Skip invalid timestamps
                }
              }
            }

            final descDocs = ascDocs.reversed.toList();

            return Column(
              children: [
                if (spots.length >= 2) LineChartCard(spots: spots),
                Expanded(
                  child: ListView.separated(
                    itemCount: descDocs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = descDocs[i];
                      final logId = d['id'] ?? d['_id'] ?? '';

                      final v = d['spo2'];
                      final note = (d['note'] ?? '').toString();
                      final pulse = (d['pulse'] ?? '').toString();
                      final device = (d['device'] ?? '').toString();
                      final whenText = _formatTs(d['ts']);

                      final subtitleParts = <String>[whenText];
                      if (pulse.trim().isNotEmpty) subtitleParts.add('Pulse: $pulse');
                      if (device.trim().isNotEmpty) subtitleParts.add('Device: $device');
                      if (note.isNotEmpty) subtitleParts.add(note);

                      return Dismissible(
                        key: ValueKey(logId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDeleteDialog(
                          context,
                          loc.t('deleteLogTitle'),
                          loc.t('deleteLogBody'),
                          loc.t('cancel'),
                          loc.t('delete'),
                        ),
                        onDismissed: (_) => TrackService.instance.deleteOxygen(
                          childId: childId,
                          logId: logId,
                        ),
                        child: ListTile(
                          title: Text('SpO2: $v%'),
                          subtitle: Text(subtitleParts.join('\n')),
                          isThreeLine: subtitleParts.length >= 3,
                          onTap: () => _edit(
                            context,
                            logId,
                            v?.toString() ?? '',
                            note,
                            pulse,
                            device,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _add(context),
            child: const Icon(Icons.add),
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
