import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class AppSettings {
  final ThemeMode themeMode;

  const AppSettings({this.themeMode = ThemeMode.system});

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(themeMode: themeMode ?? this.themeMode);
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeModeKey = 'theme_mode';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    if (value != null) {
      final mode = ThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => ThemeMode.system,
      );
      state = state.copyWith(themeMode: mode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
