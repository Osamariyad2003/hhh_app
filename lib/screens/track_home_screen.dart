import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../services/track_service.dart';
import '../widgets/lang_toggle_button.dart';

Future<bool?> _confirmDialog(BuildContext context, String title, String body, String cancel, String ok) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(ok)),
      ],
    ),
  );
}

class TrackHomeScreen extends StatelessWidget {
  const TrackHomeScreen({super.key});

  bool _isArchived(Map<String, dynamic> data) {
    final v = data['archived'];
    return v is bool ? v : false;
  }

  String? _getChildId(Map<String, dynamic> child) {
    return child['id'] ?? child['_id'];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('manageChildren')),
        actions: const [LangToggleButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/track/add-child'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: TrackService.instance.childrenStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Manage error:\n${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!;
          if (docs.isEmpty) return Center(child: Text(loc.t('noChildrenYet')));

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final data = docs[i];
              final childId = _getChildId(data);

              final name = (data['name'] ?? 'Unnamed').toString();
              final archived = _isArchived(data);

              final sex = (data['sex'] ?? '').toString().trim();
              final subtitleParts = <String>[];
              if (sex.isNotEmpty && sex != 'unspecified') subtitleParts.add('Sex: $sex');
              if (archived) subtitleParts.add('Archived');

              return ListTile(
                title: Text(name),
                subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'open' && childId != null) {
                      context.push('/track/child/$childId');
                      return;
                    }

                    if (v == 'archive' && childId != null) {
                      final ok = await _confirmDialog(
                        context,
                        'Archive child?',
                        'This hides the child from the Track screen but keeps all logs.',
                        loc.t('cancel'),
                        'Archive',
                      );
                      if (ok == true) {
                        await TrackService.instance.setChildArchived(childId: childId, archived: true);
                      }
                      return;
                    }

                    if (v == 'unarchive' && childId != null) {
                      await TrackService.instance.setChildArchived(childId: childId, archived: false);
                      return;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'open', child: Text('Open')),
                    if (!archived) const PopupMenuItem(value: 'archive', child: Text('Archive')),
                    if (archived) const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
                  ],
                ),
                onTap: () {
                  if (childId != null) {
                    context.push('/track/child/$childId');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
