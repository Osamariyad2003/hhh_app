import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/lang_toggle_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    await AuthService.instance.signInAnonymously();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('appTitle')),
        actions: const [LangToggleButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.t('appTitle'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.t('caregiverSupportSubtitle'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _start,
                child: Text(_loading ? loc.t('starting') : loc.t('start')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
