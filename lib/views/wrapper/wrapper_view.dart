import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';

import 'package:diagora/views/auth/register_view.dart';
import 'package:diagora/views/settings/settings_view.dart';
import 'package:diagora/views/home/profile/profile.dart';
import 'package:diagora/views/home/home.dart';

class WrapperView extends StatefulWidget {
  const WrapperView({
    super.key,
  });

  @override
  WrapperViewState createState() => WrapperViewState();
}

class WrapperViewState extends State<WrapperView> {
  final ApiService _api = ApiService.getInstance();
  int _currentTabIndex = 0;

  /// Les états de chaque vues des onglets pour un utilisateur par défaut.
  late final List<Widget> _basicTabs = [
    const HomeView(), // Index 0
    const ProfilePage(), // Index 1
    SettingsView(
      logout: logout,
    ), // Index 2
  ];

  // Les onglets finaux utilisés par l'utilisateur. Les onglets sont ajoutés en fonction de l'utilisateur.
  final List<Widget> _finalTabs = [];

  @override
  void initState() {
    super.initState();
    _finalTabs.addAll(_basicTabs);
  }

  void logout() {
    _api.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            for (final tab in _finalTabs)
              Navigator(
                key: ValueKey(tab),
                onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute(builder: (BuildContext context) {
                    return tab;
                  });
                },
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          selectedItemColor: Theme.of(context).primaryColor,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
