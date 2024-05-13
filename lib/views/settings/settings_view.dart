import 'package:flutter/material.dart';

import 'package:diagora/views/settings/general/my_account/my_account_view.dart';
import 'package:diagora/views/settings/display/theme/theme_view.dart';
import 'package:diagora/views/settings/others/new_document.dart';
import 'package:diagora/views/settings/others/view_documents.dart';
import 'package:diagora/views/settings/others/choose_vehicle.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/role_model.dart';

class SettingsView extends StatefulWidget {
  final Function() logout;
  final Function()? changeRoleView;

  const SettingsView({Key? key, required this.logout, this.changeRoleView})
      : super(key: key);

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final ApiService _api = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    "General",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My account'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAccountView(),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    "Display",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeView(),
                  ),
                ),
              ),
              if (widget.changeRoleView != null) ...[
                ListTile(
                  leading: const Icon(Icons.change_circle_rounded),
                  title: const Text('Change view'),
                  onTap: widget.changeRoleView,
                ),
              ],
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Text(
                    "Others",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const Divider(),
              if (widget.changeRoleView != null) ...[
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Choose vehicule'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChooseVehicleView()),
                    );
                  },
                ),
              ],
              if (Roles.manager == _api.role?.role || Roles.livreur == _api.role?.role) ...[
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Document'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewDocument(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Documents'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewDocuments(),
                      ),
                    );
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: widget.logout,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Center(
                child: Text(
                  '© 2023 Diagora',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
