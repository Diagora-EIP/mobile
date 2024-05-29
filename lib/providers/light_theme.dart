import 'package:flutter/material.dart';

final primaryColor = const Color.fromARGB(255, 66, 147, 147);

final appBarTheme = AppBarTheme(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  actionsIconTheme: const IconThemeData(
    color: Colors.white,
  ),
  toolbarHeight: 56,
);

ThemeData lightThemeDef = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  primarySwatch: MaterialColor(
    primaryColor.value,
    <int, Color>{
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor.withOpacity(1.0),
    },
  ),
  appBarTheme: appBarTheme,
);
