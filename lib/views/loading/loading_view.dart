import 'package:flutter/material.dart';

import 'package:diagora/views/auth/register_view.dart';
import 'package:diagora/views/wrapper/wrapper_view.dart';
import 'package:diagora/services/api_service.dart';

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
  void redirect() async {
    if (_api.user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterView(),
        ),
        (route) => false,
      );
    } else {
      await _api.fetchPermissions();
      if (_api.permissions != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WrapperView(),
          ),
          (route) => false,
        );
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: const Text(
              'Une erreur est survenue lors de la connexion à l\'application. Veuillez réessayer.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _api.logout();
                  redirect();
                },
                child: Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  redirect();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }
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
