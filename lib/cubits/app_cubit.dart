import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final Locale locale;
  final bool lockEnabled;
  final bool unlocked;
  final bool initialized;

  const AppState({
    required this.locale,
    required this.lockEnabled,
    required this.unlocked,
    required this.initialized,
  });

  AppState copyWith({
    Locale? locale,
    bool? lockEnabled,
    bool? unlocked,
    bool? initialized,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      unlocked: unlocked ?? this.unlocked,
      initialized: initialized ?? this.initialized,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit()
      : super(const AppState(
          locale: Locale('en'),
          lockEnabled: false,
          unlocked: true,
          initialized: false,
        ));

  static const _kLocaleCode = 'localeCode';
  static const _kLockEnabled = 'lockEnabled';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_kLocaleCode) ?? 'en';
    final locale = Locale(localeCode);

    final lockEnabled = prefs.getBool(_kLockEnabled) ?? false;
    final unlocked = !lockEnabled;

    emit(state.copyWith(
      locale: locale,
      lockEnabled: lockEnabled,
      unlocked: unlocked,
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

  Future<void> setLockEnabled(bool enabled) async {
    final unlocked = !enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLockEnabled, enabled);

    emit(state.copyWith(
      lockEnabled: enabled,
      unlocked: unlocked,
    ));
  }

  void markLocked() {
    if (!state.lockEnabled) return;
    emit(state.copyWith(unlocked: false));
  }

  void markUnlocked() {
    emit(state.copyWith(unlocked: true));
  }
}

