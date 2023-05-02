// import 'package:diagora/register.dart';
import 'package:flutter/material.dart';
import 'package:diagora/home.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final primaryColor = const Color.fromARGB(255, 66, 147, 147);

  const  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
      // home: const RegisterPage(),
      home: const HomePage(),
    );
  }
}
