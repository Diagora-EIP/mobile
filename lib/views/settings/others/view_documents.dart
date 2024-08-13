import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';

class ViewDocuments extends StatefulWidget {
  const ViewDocuments({super.key});

  @override
  State<ViewDocuments> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  final ApiService _api = ApiService.getInstance();
  final List<dynamic> documents = [];
  final bool hasDocuments = false;

  void getDocuments() {
    _api.getDocuments().then((value) {
      setState(() {
        if (value.toString() == "[]") {
          return;
        }
        documents.addAll(value);
        print(documents);
        print("Documents" + documents.toString());
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Documents'),
      ),
      body: !hasDocuments
          ? const Center(
              child: Text('No documents available'),
            )
          : SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(documents[index]),
                      onTap: () {
                        // Navigate to the document view
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
