import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/boxes.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  ThemeService() {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box(HiveBoxes.settingsBox);
      final savedTheme = box.get(_themeKey, defaultValue: 'system') as String;
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final box = Hive.box(HiveBoxes.settingsBox);
      String modeString = 'system';
      if (mode == ThemeMode.light) modeString = 'light';
      if (mode == ThemeMode.dark) modeString = 'dark';
      await box.put(_themeKey, modeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}