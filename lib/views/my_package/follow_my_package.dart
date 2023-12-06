import 'package:flutter/material.dart';

import 'package:diagora/views/my_package/my_package.dart';

class FollowMyPackage extends StatefulWidget {
  final Package item;

  const FollowMyPackage({Key? key, required this.item}) : super(key: key);

  @override
  State<FollowMyPackage> createState() => _FollowMyPackageState();
}

class _FollowMyPackageState extends State<FollowMyPackage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow My Package'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                widget.item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.blue, // Adjust the color as needed
                ),
              ),
              Text(
                widget.item.address,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16.0,
                  color: Colors.grey, // Adjust the color as needed
                ),
              ),
              Text(
                "Date: ${widget.item.date}",
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
