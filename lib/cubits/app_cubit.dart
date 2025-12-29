import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final Locale locale;
  final bool initialized;

  const AppState({
    required this.locale,
    required this.initialized,
  });

  AppState copyWith({
    Locale? locale,
    bool? initialized,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      initialized: initialized ?? this.initialized,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit()
      : super(const AppState(
          locale: Locale('en'),
          initialized: false,
        ));

  static const _kLocaleCode = 'localeCode';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_kLocaleCode) ?? 'en';
    final locale = Locale(localeCode);

    emit(state.copyWith(
      locale: locale,
      initialized: true,
    ));
  }

  Future<void> toggleLocale() async {
    final next = state.locale.languageCode == 'en' ? 'ar' : 'en';
    final locale = Locale(next);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleCode, next);

    emit(state.copyWith(locale: locale));
  }
}
