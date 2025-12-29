import 'package:chd_app_new/services/firebase/firebase_init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'core/app_theme.dart';
import 'core/app_bloc_observer.dart';
import 'cubits/ai_suggestion_cubit.dart';
import 'cubits/app_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/general_childcare_cubit.dart';

import 'localization/app_localizations.dart';
import 'services/recipe_remote_datasource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BLoC Observer for debugging
  Bloc.observer = AppBlocObserver();

  // Initialize Firebase
  await initializeFirebase();

  // Initialize Generative AI service
  RecipeRemoteDatasource.instance.initialize();

  // Initialize app cubit
  final appCubit = AppCubit();
  await appCubit.init();

  runApp(CHDApp(appCubit: appCubit));
}

class CHDApp extends StatefulWidget {
  final AppCubit appCubit;

  const CHDApp({super.key, required this.appCubit});

  @override
  State<CHDApp> createState() => _CHDAppState();
}

class _CHDAppState extends State<CHDApp> with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = AuthCubit();
    // Initialize router once to prevent recreation on rebuilds
    _router = createAppRouter(widget.appCubit, _authCubit);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock feature removed
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.appCubit),
        BlocProvider.value(value: _authCubit),

        BlocProvider(create: (context) => AISuggestionCubit()),
        BlocProvider(create: (context) => GeneralChildcareCubit()),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Health Hearts at Home',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            routerConfig: _router,
            locale: appState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
