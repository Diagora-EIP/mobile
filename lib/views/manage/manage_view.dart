import 'package:flutter/material.dart';

class ManageView extends StatefulWidget {
  const ManageView({
    Key? key,
  }) : super(key: key);

  @override
  ManageViewState createState() => ManageViewState();
}

class ManageViewState extends State<ManageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage'),
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
                    "Manage",
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
