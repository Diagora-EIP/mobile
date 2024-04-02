import 'package:flutter/material.dart';

class ViewDocuments extends StatefulWidget {
  const ViewDocuments({super.key});

  @override
  State<ViewDocuments> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  List<String> documents = [
    'Document 1',
    'Document 2',
    'Document 3',
    'Document 4',
    'Document 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Documents'),
      ),
      body: SingleChildScrollView(
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
