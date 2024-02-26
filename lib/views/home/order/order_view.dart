import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:diagora/views/home/home.dart';
import 'package:diagora/services/api_service.dart';

/// Classe permettant de simuler une commande.
class DummyOrder {
  final String name;
  final DateTime date;
  final int status; // 0: en attente, 1: en cours, 2: terminée

  const DummyOrder({
    required this.name,
    required this.date,
    required this.status,
  });
}

/// Vue de la page d'accueil des clients attendants leurs commandes.
class OrderView extends StatefulWidget {
  const OrderView({
    super.key,
  });

  @override
  OrderViewState createState() => OrderViewState();
}

class OrderViewState extends State<OrderView> {
  final ApiService _api = ApiService.getInstance();
  DateTime today = DateTime.now();
  List<dynamic> scheduleList = [];
  bool deliveryToday = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _onDaySelected(today, today);
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    DateTime chosenStart =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 1);
    DateTime chosenEnd =
        DateTime(focusDay.year + 1, focusDay.month, focusDay.day, 23);
    Future<String> allTodaysValues = _api.getSchedule(chosenStart, chosenEnd);

    allTodaysValues.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // No delivery for today
      if (value == "[]") {
        if (mounted) {
          setState(() {
            deliveryToday = false;
          });
        }
      } else {
        // There is delivery for today
        if (mounted) {
          setState(() {
            scheduleList = json.decode(value);
            scheduleList.sort((a, b) {
              return a["order"]["order_date"]
                  .compareTo(b["order"]["order_date"]);
            });
            deliveryToday = true;
          });
        }
      }
    }).catchError((error) {
      setState(() {
        deliveryToday = false;
      });
    });
    // Change the variable today to the day selected
    if (mounted) {
      setState(() {
        today = focusDay;
      });
    }
  }

  final List<DummyOrder> data = [
    DummyOrder(
      name: "Téléphone",
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 0,
    ),
    DummyOrder(
      name: "Ordinateur",
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 1,
    ),
    DummyOrder(
      name: "Montre",
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: 2,
    ),
    DummyOrder(
      name: "Télévision",
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: 0,
    ),
    DummyOrder(
      name: "Casque",
      date: DateTime.now().subtract(const Duration(days: 9)),
      status: 1,
    ),
    DummyOrder(
      name: "Livre",
      date: DateTime.now().subtract(const Duration(days: 11)),
      status: 2,
    ),
    DummyOrder(
      name: "Lampe",
      date: DateTime.now().subtract(const Duration(days: 13)),
      status: 0,
    ),
    DummyOrder(
      name: "Tapis",
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: 1,
    ),
    DummyOrder(
      name: "Chaise",
      date: DateTime.now().subtract(const Duration(days: 17)),
      status: 2,
    ),
    DummyOrder(
      name: "Table",
      date: DateTime.now().subtract(const Duration(days: 19)),
      status: 0,
    ),
    DummyOrder(
      name: "Vélo",
      date: DateTime.now().subtract(const Duration(days: 21)),
      status: 1,
    ),
    DummyOrder(
      name: "Voiture",
      date: DateTime.now().subtract(const Duration(days: 23)),
      status: 2,
    ),
    DummyOrder(
      name: "Moto",
      date: DateTime.now().subtract(const Duration(days: 25)),
      status: 0,
    ),
    DummyOrder(
      name: "Trottinette",
      date: DateTime.now().subtract(const Duration(days: 27)),
      status: 1,
    ),
    DummyOrder(
      name: "Skate",
      date: DateTime.now().subtract(const Duration(days: 29)),
      status: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const Offset begin = Offset(-1.0, 0.0);
                  const Offset end = Offset(0.0, 0.0);
                  var curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
              (route) => false,
            );
          },
        ),
        title: const Text('Mes commandes'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : deliveryToday
              ? ListView.separated(
                  itemCount: scheduleList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Card(
                        child: ListTile(
                          title: Text(
                              "${scheduleList[index]["order"]["description"]}"),
                          // "${scheduleList[index]["order"]["description"]} (${data[index].status == 0 ? "En attente" : data[index].status == 1 ? "En cours" : "Terminée"})"),
                          subtitle: Text(
                            "Commandé le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(
                          scheduleList[index]["order"]["order_date"]))}",

                            // "${data[index].status == 2 ? "Livré le" : "Commandé le"} ${data[index].date.day.toString().padLeft(2, '0')}/${data[index].date.month.toString().padLeft(2, '0')}/${data[index].date.year}",
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.watch_later_outlined,
                              color: Colors.orange,
                              // data[index].status == 0
                              //     ? Icons.watch_later_outlined
                              //     : data[index].status == 1
                              //         ? Icons.timer
                              //         : Icons.done,
                              // color: data[index].status == 0
                              //     ? Colors.orange
                              //     : data[index].status == 1
                              //         ? Colors.blue
                              //         : Colors.green,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(
                            //       data[index].status == 0
                            //           ? "Commande en attente"
                            //           : data[index].status == 1
                            //               ? "Commande en cours"
                            //               : "Commande terminée",
                            //     ),
                            //     duration: const Duration(seconds: 1),
                            //     showCloseIcon: true,
                            //   ),
                            // );
                          },
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                )
              : const Center(
                  child: Text("Aucune commande pour aujourd'hui"),
                ),
    );
  }
}
