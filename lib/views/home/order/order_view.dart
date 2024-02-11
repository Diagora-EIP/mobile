import 'package:flutter/material.dart';

import 'package:diagora/views/home/home.dart';
import 'package:diagora/views/home/calendar/new_delivery.dart';

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
  DateTime pickedDate = DateTime.now();

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewDelivery(pickedDate: pickedDate),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: Card(
              child: ListTile(
                title: Text(
                    "${data[index].name} (${data[index].status == 0 ? "En attente" : data[index].status == 1 ? "En cours" : "Terminée"})"),
                subtitle: Text(
                  "${data[index].status == 2 ? "Livré le" : "Commandé le"} ${data[index].date.day.toString().padLeft(2, '0')}/${data[index].date.month.toString().padLeft(2, '0')}/${data[index].date.year}",
                ),
                leading: Icon(
                  data[index].status == 0
                      ? Icons.watch_later_outlined
                      : data[index].status == 1
                          ? Icons.timer
                          : Icons.done,
                  color: data[index].status == 0
                      ? Colors.orange
                      : data[index].status == 1
                          ? Colors.blue
                          : Colors.green,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        data[index].status == 0
                            ? "Commande en attente"
                            : data[index].status == 1
                                ? "Commande en cours"
                                : "Commande terminée",
                      ),
                      duration: const Duration(seconds: 1),
                      showCloseIcon: true,
                    ),
                  );
                },
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
