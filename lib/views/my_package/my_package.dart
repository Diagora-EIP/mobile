import 'package:flutter/material.dart';

import 'package:diagora/views/my_package/follow_my_package.dart';

class MyPackages extends StatefulWidget {
  const MyPackages({super.key});

  @override
  State<MyPackages> createState() => _MyPackagesState();
}

class Package {
  final String name;
  final String address;
  final String date;

  Package({
    required this.name,
    required this.address,
    required this.date,
  });
}

class _MyPackagesState extends State<MyPackages> {
  List<Package> packages = [
    Package(name: "Package 1", address: "81 Onondaga ave, San Francisco", date: "2024-01-01"),
    Package(name: "Package 2", address: "18 rue des peupliers, Clapiers, France", date: "2024-02-15"),
    Package(name: "Package 3", address: "Cupertino", date: "2024-03-30"),
  ];

  @override
  Widget build(BuildContext context) {
    bool isScreenHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Packages List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isScreenHorizontal ? 3 : 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: packages.length,
          itemBuilder: (BuildContext context, int index) {
            Package currentPackage = packages[index];

            return Card(
              child: ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentPackage.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.blue, // Adjust the color as needed
                      ),
                    ),
                    Text(
                      currentPackage.address,
                      // textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      currentPackage.date,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowMyPackage(item: currentPackage),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
