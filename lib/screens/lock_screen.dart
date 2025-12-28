import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../localization/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../widgets/lang_toggle_button.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _tryBiometric() async {
    final loc = AppLocalizations.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    final canBio = await AppLockService.instance.canUseBiometric();
    if (!canBio) {
      setState(() {
        _busy = false;
        _error = loc.t('biometricUnavailable');
      });
      return;
    }

    final ok = await AppLockService.instance.biometricUnlock(
      localizedReason: loc.t('unlock'),
    );
    if (!mounted) return;

    if (ok) {
      context.read<AppCubit>().markUnlocked();
      return;
    }

    setState(() {
      _busy = false;
      _error = loc.t('unlockFailed');
    });
  }

  Future<void> _tryPin() async {
    final loc = AppLocalizations.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    final ok = await AppLockService.instance.verifyPin(_pin.text.trim());
    if (!mounted) return;

    if (ok) {
      context.read<AppCubit>().markUnlocked();
      return;
    }

    setState(() {
      _busy = false;
      _error = loc.t('unlockFailed');
    });
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('appTitle')),
        actions: const [LangToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              loc.t('unlock'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                labelText: loc.t('enterPin'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _tryPin,
                child: Text(loc.t('unlock')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : _tryBiometric,
                child: Text(loc.t('useBiometric')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
