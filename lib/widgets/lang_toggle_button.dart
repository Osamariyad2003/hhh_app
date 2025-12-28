import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../localization/app_localizations.dart';

class LangToggleButton extends StatelessWidget {
  const LangToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return IconButton(
      tooltip: loc.t('language'),
      icon: const Icon(Icons.language),
      onPressed: () => context.read<AppCubit>().toggleLocale(),
    );
  }
}
