import 'package:diagora/views/home/order/order_view.dart';
import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';

import 'package:diagora/views/home/calendar/calendar.dart';
import 'package:diagora/views/home/home.dart';
import 'package:diagora/views/stats/stats.dart';
import 'package:diagora/models/role_model.dart';
import 'package:diagora/views/admin/admin_view.dart';
import 'package:diagora/views/auth/register_view.dart';
import 'package:diagora/views/manage/manage_view.dart';
import 'package:diagora/views/profile/profile_view.dart';
import 'package:diagora/views/my_package/my_package.dart';
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
  bool showManager = false;
  bool managerView = true;
  bool showLivreur = false;
  bool showClient = false;

  /// Les onglets utilisés par l'utilisateur. Les onglets sont ajoutés en fonction des permissions de l'utilisateur dans la fonction [initViews].
  final List<Widget> _finalTabs = [];
  final List<Widget> _managerTabs = [];

  /// Initialise les onglets en fonction des permissions de l'utilisateur pour remplir la liste [_finalTabs].
  void initViews() {
    if (_api.role?.role == Roles.admin) {
      // Si l'utilisateur est un admin
      _finalTabs.addAll([
        const CalendarView(),
        const OrderView(),
        const AdminView(),
        const ProfileView(),
      ]);
      showAdmin = true;
    } else if (_api.role?.role == Roles.manager) {
      // Si l'utilisateur est un manager
      _finalTabs.addAll([
        const CalendarView(),
        const OrderView(),
        const ProfileView(),
      ]);
      _managerTabs.addAll([
        const CalendarView(),
        const ProfileView(),
      ]);
      showManager = true;
    } else if (_api.role?.role == Roles.livreur) {
      // Si l'utilisateur est un livreur
      _finalTabs.addAll([
        const CalendarView(),
        const OrderView(),
        const ProfileView(),
      ]);
      showLivreur = true;
    } else if (_api.role?.role == Roles.client ||
        _api.role?.role == Roles.user) {
      // Si l'utilisateur est un client
      _finalTabs.addAll([
        const MyPackages(),
        const ProfileView(),
      ]);
      showClient = true;
    }
  }

  @override
  void initState() {
    super.initState();
    initViews();
  }

  void changeRoleView() {
    setState(() {
      _currentTabIndex = 0;
      managerView = !managerView;
    });
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
            if (showManager && managerView == false) ...{
              // Si l'utilisateur est un manager voulant voir les onglets de livreur
              for (final tab in _managerTabs)
                Navigator(
                  key: ValueKey(tab),
                  onGenerateRoute: (RouteSettings settings) {
                    return MaterialPageRoute(builder: (BuildContext context) {
                      return tab;
                    });
                  },
                ),
            } else ...{
              for (final tab in _finalTabs)
                Navigator(
                  key: ValueKey(tab),
                  onGenerateRoute: (RouteSettings settings) {
                    return MaterialPageRoute(builder: (BuildContext context) {
                      return tab;
                    });
                  },
                ),
            }
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
            if (showAdmin) ...[
              // Si l'utilisateur est un admin
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendrier',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Commandes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
            ],
            if (showManager) ...[
              // Si l'utilisateur est un manager
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendrier',
              ),
              if (managerView) ...[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Commandes',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Manage',
                ),
              ],
            ],
            if (showLivreur) ...[
              // Si l'utilisateur est un livreur
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendrier',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Order',
              ),
            ],
            if (showClient) ...[
              // Si l'utilisateur est un utilisateur normal
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'My Packages',
              ),
            ],
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
