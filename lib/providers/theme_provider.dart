import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.system;

  ThemeData get lightTheme => lightThemeDef;
  ThemeData get darkTheme => darkThemeDef;
  ThemeMode get themeMode => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> reloadTheme() async {
    await _loadTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeData =
        prefs.getString("themeMode") ?? ThemeMode.system.toString();

    switch (themeModeData) {
      case "ThemeMode.system":
        _currentTheme = ThemeMode.system;
        break;
      case "ThemeMode.light":
        _currentTheme = ThemeMode.light;
        break;
      case "ThemeMode.dark":
        _currentTheme = ThemeMode.dark;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeData =
        prefs.getString("themeMode") ?? ThemeMode.system.toString();

    switch (themeModeData) {
      case "ThemeMode.system":
        return ThemeMode.system;
      case "ThemeMode.light":
        return ThemeMode.light;
      case "ThemeMode.dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("themeMode", theme.toString());
    _currentTheme = theme;
  }
}
