import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';

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
  List<dynamic> filteredScheduleList = [];
  bool deliveryToday = true;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchOrders(today, DateTime(today.year + 1, today.month, today.day));
    searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterOrders);
    searchController.dispose();
    super.dispose();
  }

  void _fetchOrders(DateTime start, DateTime end) {
    DateTime realStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
    DateTime realEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    Future<String> allTodaysValues = _api.getSchedule(realStart, realEnd);

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
            scheduleList = [];
            filteredScheduleList = [];
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
            _filterOrders();
            deliveryToday = true;
          });
        }
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        deliveryToday = false;
        scheduleList = [];
        filteredScheduleList = [];
      });
    });
  }

  void _filterOrders() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      filteredScheduleList = scheduleList.where((order) {
        final orderDescription = order["order"]["description"].toLowerCase();
        final orderDate = DateTime.parse(order["order"]["order_date"]);
        final matchesDescription = orderDescription.contains(searchQuery);
        final matchesDateRange = startDate == null ||
            endDate == null ||
            (orderDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
                orderDate.isBefore(endDate!.add(const Duration(days: 1))));
        return matchesDescription && matchesDateRange;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate!, end: endDate!),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked != DateTimeRange(start: startDate!, end: endDate!)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchOrders(picked.start, picked.end);
    }
  }

  void _reloadOrders() {
    if (startDate != null && endDate != null) {
      _fetchOrders(startDate!, endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _reloadOrders();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: const Text('Sélectionner une plage de dates'),
              onPressed: () {
                _selectDateRange(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une commande',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : deliveryToday
                    ? ListView.separated(
                        itemCount: filteredScheduleList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                    "${filteredScheduleList[index]["order"]["description"]}"),
                                subtitle: Text(
                                  "Commandé le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(filteredScheduleList[index]["order"]["order_date"]))}",
                                ),
                                leading: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.watch_later_outlined,
                                    color: Colors.orange,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {},
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                      )
                    : const Center(
                        child:
                            Text("Aucune commande pour cette plage de temps."),
                      ),
          ),
        ],
      ),
    );
  }
}
