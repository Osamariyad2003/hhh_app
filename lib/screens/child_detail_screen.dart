import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../services/track_service.dart';
import '../widgets/lang_toggle_button.dart';

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
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(delete)),
      ],
    ),
  );
}

class ChildDetailScreen extends StatelessWidget {
  final String childId;
  const ChildDetailScreen({super.key, required this.childId});

  Future<void> _deleteChild(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    final ok = await _confirmDeleteDialog(
      context,
      loc.t('deleteChildTitle'),
      loc.t('deleteChildBody'),
      loc.t('cancel'),
      loc.t('delete'),
    );
    if (ok != true) return;

    try {
      await TrackService.instance.deleteChild(childId: childId);
      if (!context.mounted) return;
      context.go('/track');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('failedDeleteChild'))),
      );
    }
  }

  Future<void> _editChild(BuildContext context, Map<String, dynamic> data) async {
    final loc = AppLocalizations.of(context);

    final nameCtrl = TextEditingController(text: (data['name'] ?? '').toString());
    final notesCtrl = TextEditingController(text: (data['notes'] ?? '').toString());

    DateTime? dob;
    final dobRaw = data['dob'];
    if (dobRaw is String) {
      try {
        dob = DateTime.parse(dobRaw);
      } catch (e) {
        // Invalid date string
      }
    }

    String sex = (data['sex'] ?? 'unspecified').toString().trim();
    if (sex.isEmpty) sex = 'unspecified';

    bool archived = (data['archived'] is bool) ? (data['archived'] as bool) : false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit child'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: loc.t('childName')),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(dob == null ? loc.t('pickDob') : DateFormat('yyyy-MM-dd').format(dob!)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime(now.year - 18, 1, 1),
                          lastDate: now,
                          initialDate: dob ?? DateTime(now.year - 1, now.month, now.day),
                        );
                        if (picked != null) setState(() => dob = picked);
                      },
                      child: Text(loc.t('choose')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: sex,
                  decoration: const InputDecoration(labelText: 'Sex'),
                  items: const [
                    DropdownMenuItem(value: 'unspecified', child: Text('Unspecified')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => sex = v ?? 'unspecified'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: archived,
                  onChanged: (v) => setState(() => archived = v),
                  title: const Text('Archived'),
                  subtitle: const Text('Hide this child from the dashboard'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.t('cancel'))),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.t('save'))),
          ],
        ),
      ),
    );

    if (ok == true) {
      try {
        await TrackService.instance.updateChild(
          childId: childId,
          name: nameCtrl.text.trim(),
          dob: dob,
          sex: sex,
          notes: notesCtrl.text.trim(),
          archived: archived,
        );

        if (context.mounted && archived) {
          context.go('/track');
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.t('failedUpdateChild'))),
          );
        }
      }
    }

    nameCtrl.dispose();
    notesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return StreamBuilder<Map<String, dynamic>?>(
      stream: TrackService.instance.childStream(childId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Child')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Child error:\n${snapshot.error}'),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data ?? {};
        final name = (data['name'] ?? 'Child').toString();

        final dob = data['dob'];
        final dobText = _formatDob(dob);
        final ageText = _ageFromDob(dob);

        final rawSex = (data['sex'] ?? '').toString().trim();
        final sex = (rawSex.isEmpty || rawSex == 'unspecified') ? '' : rawSex;

        final notes = (data['notes'] ?? '').toString().trim();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editChild(context, data),
                ),
                IconButton(
                  tooltip: loc.t('settings'),
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.go('/settings'),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete_child') _deleteChild(context);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'delete_child', child: Text(loc.t('delete'))),
                  ],
                ),
                const LangToggleButton(),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: loc.t('weight')),
                  Tab(text: loc.t('feeding')),
                  Tab(text: loc.t('oxygen')),
                ],
              ),
            ),
            body: Column(
              children: [
                if (dobText.isNotEmpty || ageText.isNotEmpty || sex.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                      child: Text(notes),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _WeightsTab(childId: childId),
                      _FeedingsTab(childId: childId),
                      _OxygenTab(childId: childId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  const _LineChartCard({required this.spots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minX = spots.first.x;
    final maxX = spots.last.x;

    return SizedBox(
      height: 220,
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
                          child: Text(DateFormat('dd/MM').format(dt), style: const TextStyle(fontSize: 11)),
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

class _WeightsTab extends StatelessWidget {
  final String childId;
  const _WeightsTab({required this.childId});

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
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(labelText: 'Clothes (optional)'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Not set')),
                    DropdownMenuItem(value: 'with_diaper', child: Text('With diaper')),
                    DropdownMenuItem(value: 'no_clothes', child: Text('No clothes')),
                  ],
                  onChanged: (v) => setState(() => clothes = v ?? 'none'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.t('cancel'))),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.t('save'))),
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
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(labelText: 'Clothes (optional)'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Not set')),
                    DropdownMenuItem(value: 'with_diaper', child: Text('With diaper')),
                    DropdownMenuItem(value: 'no_clothes', child: Text('No clothes')),
                  ],
                  onChanged: (v) => setState(() => clothes = v ?? 'none'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.t('cancel'))),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.t('save'))),
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
          stream: TrackService.instance.weightsStream(childId, descending: false, limit: 200),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Error'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final ascDocs = snapshot.data!;
            if (ascDocs.isEmpty) return const Center(child: Text('No logs'));

            final spots = <FlSpot>[];
            for (final d in ascDocs) {
              final ts = d['ts'];
              final kg = d['valueKg'];
              if (ts is String && kg is num) {
                try {
                  final dt = DateTime.parse(ts);
                  spots.add(FlSpot(dt.millisecondsSinceEpoch.toDouble(), kg.toDouble()));
                } catch (e) {
                  // Invalid date, skip
                }
              }
            }

            final descDocs = ascDocs.reversed.toList();

            return Column(
              children: [
                if (spots.length >= 2) _LineChartCard(spots: spots),
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
                      if (clothes.trim().isNotEmpty) subtitleParts.add('Clothes: $clothes');
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
                        onDismissed: (_) => TrackService.instance.deleteWeight(childId: childId, logId: logId),
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

class _FeedingsTab extends StatelessWidget {
  final String childId;
  const _FeedingsTab({required this.childId});

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
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(labelText: 'Method (optional)'),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.t('cancel'))),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.t('save'))),
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
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(labelText: 'Method (optional)'),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.t('cancel'))),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.t('save'))),
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
          stream: TrackService.instance.feedingsStream(childId, descending: true, limit: 200),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Error'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!;
            if (docs.isEmpty) return const Center(child: Text('No logs'));

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
                if (method.trim().isNotEmpty) subtitleParts.add('Method: $method');
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
                  onDismissed: (_) => TrackService.instance.deleteFeeding(childId: childId, logId: logId),
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

class _OxygenTab extends StatelessWidget {
  final String childId;
  const _OxygenTab({required this.childId});

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
        content: SingleChildScrollView(
          child: Column(
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
        content: SingleChildScrollView(
          child: Column(
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
            if (snapshot.hasError) return const Center(child: Text('Error'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final ascDocs = snapshot.data!;
            if (ascDocs.isEmpty) return const Center(child: Text('No logs'));

            final spots = <FlSpot>[];
            for (final d in ascDocs) {
              final ts = d['ts'];
              final v = d['spo2'];
              if (ts is String && v is num) {
                try {
                  final dt = DateTime.parse(ts);
                  spots.add(FlSpot(dt.millisecondsSinceEpoch.toDouble(), v.toDouble()));
                } catch (e) {
                  // Invalid date, skip
                }
              }
            }

            final descDocs = ascDocs.reversed.toList();

            return Column(
              children: [
                if (spots.length >= 2) _LineChartCard(spots: spots),
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
                        onDismissed: (_) => TrackService.instance.deleteOxygen(childId: childId, logId: logId),
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
