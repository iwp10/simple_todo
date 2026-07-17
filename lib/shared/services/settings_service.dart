import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';
  static const String _themeModeKey = 'theme_mode';

  Future<ThemeMode> loadThemeMode() async {
    final box = await Hive.openBox<String>(_settingsBoxName);
    final storedValue = box.get(_themeModeKey);

    switch (storedValue) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final box = await Hive.openBox<String>(_settingsBoxName);
    await box.put(_themeModeKey, themeMode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  final settingsService = ref.read(settingsServiceProvider);
  return ThemeModeController(settingsService);
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._settingsService) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  final SettingsService _settingsService;

  Future<void> _loadThemeMode() async {
    state = await _settingsService.loadThemeMode();
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) {
      return;
    }

    state = themeMode;
    await _settingsService.saveThemeMode(themeMode);
  }
}
