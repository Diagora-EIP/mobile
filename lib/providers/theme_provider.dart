import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'diagora_themeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final savedThemeMode = sharedPreferences.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = _themeModeFromString(savedThemeMode);
    }
  }

  Future<void> setThemeMode(ThemeModeOption themeModeOption) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final newThemeMode = _themeModeFromOption(themeModeOption);
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      await sharedPreferences.setString(
        _themeModeKey,
        themeModeOption.toString(),
      );
      notifyListeners();
    }
  }

  ThemeMode _themeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeModeOption.light':
        return ThemeMode.light;
      case 'ThemeModeOption.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeMode _themeModeFromOption(ThemeModeOption themeModeOption) {
    switch (themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static ThemeProvider of(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }
}
