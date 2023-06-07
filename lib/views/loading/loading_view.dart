import 'package:diagora/views/auth/register_view.dart';
import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/home.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({
    Key? key,
  }) : super(key: key);

  @override
  LoadingViewState createState() => LoadingViewState();
}

class LoadingViewState extends State<LoadingView> {
  final ApiService _api = ApiService.getInstance();

  @override
  void initState() {
    super.initState();
    loading();
  }

  /// Permet de charger l'API pour ensuite lancer [redirect], pour rediriger vers la page d'accueil ou d'authentification
  Future<void> loading() async {
    while (!_api.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Future.delayed(const Duration(seconds: 2));
    redirect();
  }

  /// Redirige vers la page d'accueil ou d'authentification en fonction de si l'utilisateur est connecté ou non
  void redirect() {
    if (_api.token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterView(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              'assets/images/diagora.png',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
