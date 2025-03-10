import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:diagora/providers/theme_provider.dart';
import 'package:diagora/views/loading/loading_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
        "coding is life foreground", "coding is life foreground service",
        description: "This is channel des....", importance: Importance.high);

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

  // await initservice();

  // Run the application
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

Future<void> initservice() async {
  var service = FlutterBackgroundService();
  //set for ios
  if (Platform.isIOS) {
    await flutterLocalPlugin.initialize(
        const InitializationSettings(iOS: DarwinInitializationSettings()));
  }

  await flutterLocalPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  //service init and start
  await service.configure(
      iosConfiguration:
          IosConfiguration(onBackground: iosBackground, onForeground: onStart),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId:
              "coding is life", //comment this line if show white screen and app crash
          initialNotificationTitle: "Coding is life",
          initialNotificationContent: "Awsome Content",
          foregroundServiceNotificationId: 90));
  service.startService();

  //for ios enable background fetch from add capability inside background mode
}

//onstart method
@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  service.on("setAsForeground").listen((event) {
    print("foreground ===============");
  });

  service.on("setAsBackground").listen((event) {
    print("background ===============");
  });

  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  print("Background service ${DateTime.now()}");
}

//iosbackground
@pragma("vm:entry-point")
Future<bool> iosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
        return MaterialApp(
          title: 'Diagora',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          home: const LoadingView(),
          navigatorObservers: [routeObserver],
        );
      },
    );
  }
}
