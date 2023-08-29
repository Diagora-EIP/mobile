import 'dart:ui';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diagora/providers/theme_provider.dart';

import 'package:diagora/views/loading/loading_view.dart';

/// Fonction principale de l'application.
///
/// Cette fonction initialise Firebase, puis lance l'application.
void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.setAnalyticsCollectionEnabled(true);
  analytics.logAppOpen().ignore();

  // Firebase Crashlytics
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  crashlytics.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {
    // Permet d'envoyer les erreurs de Flutter à Crashlytics
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // Permet d'envoyer les erreurs de l'application à Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialise ThemeProvider et récupère le thème de l'application
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Run the application
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

/// Classe principale de l'application.
///
/// Cette classe initialise le thème de l'application, puis lance la vue de chargement.
class MyApp extends StatelessWidget {
  final primaryColor = const Color.fromARGB(255, 66, 147, 147);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
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

        return MaterialApp(
          title: 'Diagora',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
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
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
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
          ),
          home: const LoadingView(),
        );
      },
    );
  }
}
