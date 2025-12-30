import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_states.dart';
import '../widgets/lang_toggle_button.dart';
import '../widgets/empty_state_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.t('appTitle')),
        actions: const [LangToggleButton()],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return EmptyStateWidget(
            icon: Icons.favorite,
            title: loc.t('appTitle'),
            message: '${loc.t('caregiverSupportSubtitle')}\n\nPreparing your app...',
            isLoading: true,
          );
        },
      ),
    );
  }
}
