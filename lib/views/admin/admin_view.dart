import 'package:flutter/material.dart';

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
      body: const Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, top: 16.0),
                  child: Text(
                    "Admin",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
