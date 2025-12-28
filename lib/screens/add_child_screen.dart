import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../services/track_service.dart';
import '../widgets/lang_toggle_button.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _name = TextEditingController();
  final _notes = TextEditingController();

  String _sex = 'unspecified';
  DateTime? _dob;

  bool _saving = false;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 18, 1, 1),
      lastDate: now,
      initialDate: DateTime(now.year - 1, now.month, now.day),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty || _dob == null) return;

    setState(() => _saving = true);
    try {
      final id = await TrackService.instance.addChild(
        name: name,
        dob: _dob!,
        archived: false,
        sex: _sex,
        notes: _notes.text.trim(),
      );
      if (!mounted) return;
      context.pushReplacement('/track/child-info/$id');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('failedCreateChild'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final dobText = _dob == null ? loc.t('pickDob') : _dob!.toLocal().toString().split(' ').first;
    final canSave = !_saving && _name.text.trim().isNotEmpty && _dob != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('addChild')),
        actions: const [LangToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: loc.t('childName')),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(dobText)),
                TextButton(onPressed: _pickDob, child: Text(loc.t('choose'))),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(labelText: 'Sex'),
              items: const [
                DropdownMenuItem(value: 'unspecified', child: Text('Unspecified')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (v) => setState(() => _sex = v ?? 'unspecified'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave ? _save : null,
                child: Text(_saving ? loc.t('saving') : loc.t('create')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
