import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';

import 'package:diagora/views/home/home.dart';
import 'package:diagora/views/auth/register_view.dart';
import 'package:diagora/views/admin/admin_view.dart';
// import 'package:diagora/views/manage/manage_view.dart';
import 'package:diagora/views/profile/profile_view.dart';
import 'package:diagora/views/settings/settings_view.dart';

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
  bool showAdmin = false;
  bool showManage = false;

  /// Les onglets utilisés par l'utilisateur. Les onglets sont ajoutés en fonction des permissions de l'utilisateur dans la fonction [initViews].
  final List<Widget> _finalTabs = [];

  /// Initialise les onglets en fonction des permissions de l'utilisateur pour remplir la liste [_finalTabs].
  void initViews() {
    if (_api.permissions?.isAdmin == true) {
      // Si l'utilisateur est un admin
      _finalTabs.addAll([
        const HomeView(),
        const AdminView(),
        const ProfileView(),
        SettingsView(
          logout: logout,
        ),
      ]);
      showAdmin = true;
    }
    // else if (_api.permissions?.isManager == true) {
    //   // Si l'utilisateur est un manager
    //   _finalTabs.addAll([
    //     const HomeView(),
    //     const ManageView(),
    //     const ProfileView(),
    //     SettingsView(
    //       logout: logout,
    //     ),
    //   ]);
    //   showManage = true;
    // }
    else {
      // Si l'utilisateur est un utilisateur normal
      _finalTabs.addAll([
        const HomeView(),
        const ProfileView(),
        SettingsView(
          logout: logout,
        ),
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    initViews();
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            if (showAdmin) ...[
              // Si l'utilisateur est un admin
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
            ],
            if (showManage) ...[
              // Si l'utilisateur est un manager
              const BottomNavigationBarItem(
                icon: Icon(Icons.manage_accounts),
                label: 'Manage',
              ),
            ],
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
