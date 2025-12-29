import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final Locale locale;
  final bool initialized;
  final ThemeMode themeMode;

  const AppState({
    required this.locale,
    required this.initialized,
    required this.themeMode,
  });

  AppState copyWith({
    Locale? locale,
    bool? initialized,
    ThemeMode? themeMode,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      initialized: initialized ?? this.initialized,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit()
      : super(const AppState(
          locale: Locale('en'),
          initialized: false,
          themeMode: ThemeMode.light,
        ));

  static const _kLocaleCode = 'localeCode';
  static const _kThemeMode = 'themeMode';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_kLocaleCode) ?? 'en';
    final locale = Locale(localeCode);

    final themeModeString = prefs.getString(_kThemeMode) ?? 'light';
    final themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

    emit(state.copyWith(
      locale: locale,
      themeMode: themeMode,
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

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');

    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleThemeMode() async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
