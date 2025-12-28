import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../localization/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../widgets/lang_toggle_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _setPin() async {
    final loc = AppLocalizations.of(context);

    final pin = TextEditingController();
    final confirm = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.t('setPin')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.t('pin')),
            ),
            TextField(
              controller: confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: loc.t('confirmPin')),
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
      if (pin.text.trim().isEmpty || pin.text.trim() != confirm.text.trim()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('pinMismatch'))));
      } else {
        await AppLockService.instance.setPin(pin.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('pinSet'))));
      }
    }

    pin.dispose();
    confirm.dispose();
  }

  Future<void> _lockNow() async {
    setState(() => _busy = true);
    context.read<AppCubit>().markLocked();
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final enabled = appState.lockEnabled;

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.t('settings')),
            actions: const [LangToggleButton()],
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: Text(loc.t('requireUnlock')),
                subtitle: Text(loc.t('appLock')),
                value: enabled,
                onChanged: (v) async {
                  setState(() => _busy = true);
                  await context.read<AppCubit>().setLockEnabled(v);
                  setState(() => _busy = false);
                },
              ),
              ListTile(
                title: Text(loc.t('setPin')),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : _setPin,
              ),
              ListTile(
                title: Text(loc.t('unlockNow')),
                trailing: const Icon(Icons.lock),
                onTap: (!enabled || _busy) ? null : _lockNow,
              ),
            ],
          ),
        );
      },
    );
  }
}
