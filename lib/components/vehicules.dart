import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';

class VehiculesComponent extends StatefulWidget {
  final int userId;
  final String pageTitle;

  const VehiculesComponent({
    Key? key,
    required this.userId,
    required this.pageTitle,
  }) : super(key: key);

  @override
  VehiculesComponentState createState() => VehiculesComponentState();
}

class VehiculesComponentState extends State<VehiculesComponent> {
  final ApiService _api = ApiService.getInstance();
  bool fetching = false;
  dynamic data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        fetching = true;
      });
      data = await _api.getVehicules(userId: widget.userId);
      setState(() {
        fetching = false;
      });
    } catch (e) {
      _close();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occured while fetching vehicules.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        fetching = false;
      });
    }
  }

  void _close() {
    Navigator.pop(context);
  }

  void openModalVehicule({vehicule}) async {
    String action = vehicule == null ? 'Add vehicule' : 'Edit vehicule';
    var vehiculeData = {
      "userId": widget.userId,
      "name": vehicule == null ? "" : vehicule["vehicle_name"],
      "dimentions": vehicule == null ? "" : vehicule["dimentions"],
      "capacity": vehicule == null ? 0 : vehicule["capacity"],
    };
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: vehiculeData["name"],
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          vehiculeData["name"] = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: vehiculeData["dimentions"],
                      decoration: const InputDecoration(
                        labelText: 'Dimentions',
                      ),
                      onChanged: (value) {
                        setState(() {
                          vehiculeData["dimentions"] = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: vehiculeData["capacity"].toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                      ),
                      onChanged: (value) {
                        if (value == "") {
                          value = "0";
                        }
                        try {
                          int.parse(value);
                        } catch (e) {
                          value = "0";
                        }
                        setState(() {
                          vehiculeData["capacity"] = int.parse(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Submit btn
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: OutlinedButton(
                  onPressed: vehiculeData["capacity"] > 0 &&
                    vehiculeData["name"] != "" &&
                    vehiculeData["dimentions"] != ""
                   ? () async {
                    if (vehiculeData["capacity"] == 0) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Capacity must be greater than 0.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (vehiculeData["name"] == "") {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name cannot be empty.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (vehiculeData["dimentions"] == "") {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dimentions cannot be empty.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    try {
                      if (vehicule == null) {
                        await addVehicule(vehiculeData);
                      } else {
                        vehiculeData["vehicle_id"] = vehicule["vehicle_id"];
                        await editVehicule(vehiculeData);
                      }
                    } catch (e) {
                      // ignore: avoid_print
                      print(e);
                    }
                  } : null,
                  child: Text(action),
                ),
              ),
            ),
            if (vehicule != null) ...[
              // Delete btn
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () async {
                      try {
                        vehiculeData["vehicle_id"] = vehicule["vehicle_id"];
                        _confirmDelete(vehiculeData);
                      } catch (e) {
                        // ignore: avoid_print
                        print(e);
                      }
                    },
                    child: const Text("Delete vehicule"),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(vehiculeData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete this vehicule?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  await deleteVehicule(vehiculeData);
                } catch (e) {
                  // ignore: avoid_print
                  print(e);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addVehicule(vehiculeData) async {
    _close();
    try {
      setState(() {
        fetching = true;
      });
      var response = await _api.addVehicule(
        userId: vehiculeData["userId"],
        name: vehiculeData["name"] ?? "",
        dimentions: vehiculeData["dimentions"] ?? "",
        capacity: vehiculeData["capacity"] ?? 0,
      );
      if (response == false) {
        throw Exception("Error while adding vehicule");
      }
      fetchData();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occured while adding vehicule.'),
          duration: Duration(seconds: 2),
        ),
      );
      // ignore: avoid_print
      print(e);
      setState(() {
        fetching = false;
      });
    }
  }

  Future<void> editVehicule(vehiculeData) async {
    _close();
    try {
      setState(() {
        fetching = true;
      });
      var response = await _api.editVehicule(
        vehiculeId: vehiculeData["vehicle_id"],
        userId: vehiculeData["userId"],
        name: vehiculeData["name"] ?? "",
        dimentions: vehiculeData["dimentions"] ?? "",
        capacity: vehiculeData["capacity"] ?? 0,
      );
      if (response == false) {
        throw Exception("Error while editting vehicule");
      }
      fetchData();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occured while editting vehicule.'),
          duration: Duration(seconds: 2),
        ),
      );
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> deleteVehicule(vehiculeData) async {
    _close();
    try {
      setState(() {
        fetching = true;
      });
      var response = await _api.deleteVehicule(
        vehiculeId: vehiculeData["vehicle_id"],
      );
      if (response == false) {
        throw Exception("Error while deleting vehicule");
      }
      fetchData();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occured while deleting vehicule.'),
          duration: Duration(seconds: 2),
        ),
      );
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.pageTitle),
          // add + button to add new vehicule
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: fetching ? null : () => openModalVehicule(),
            ),
          ]),
      body: fetching
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.isEmpty) ...[
                      const SizedBox(height: 60),
                      const Center(
                        child: Text(
                          'No vehicules found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                    for (dynamic vehicule in data) ...[
                      if (data.indexOf(vehicule) != 0) ...[
                        const Divider(),
                      ],
                      ListTile(
                        title: Text(vehicule["vehicle_name"]),
                        subtitle: Text(
                          "Dimentions: ${vehicule["dimentions"]} | Capacity: ${vehicule["capacity"]}",
                        ),
                        onTap: () {
                          openModalVehicule(vehicule: vehicule);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
