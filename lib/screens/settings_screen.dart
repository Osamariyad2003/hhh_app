import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubits/app_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../localization/app_localizations.dart';
import '../widgets/lang_toggle_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  Future<void> _logout() async {
    final loc = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('logout')),
        content: Text(loc.t('logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.t('logout')),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _busy = true);

      try {
        await context.read<AuthCubit>().signOut();
        
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _busy = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [LangToggleButton()],
      ),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: appState.themeMode == ThemeMode.dark,
                onChanged: (v) async {
                  setState(() => _busy = true);
                  await context.read<AppCubit>().toggleThemeMode();
                  setState(() => _busy = false);
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  loc.t('logout'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: _busy ? null : _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}
