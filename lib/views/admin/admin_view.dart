import 'package:flutter/material.dart';

import 'package:diagora/views/admin/users/users_view.dart';
import 'package:diagora/views/admin/companies/companies_view.dart';

class AdminView extends StatefulWidget {
  const AdminView({
    Key? key,
  }) : super(key: key);

  @override
  AdminViewState createState() => AdminViewState();
}

class AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
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
                    "Users-related data",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Users'),
                leading: const Icon(Icons.people),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersView(),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Companies'),
                leading: const Icon(Icons.business_center),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompaniesView(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
