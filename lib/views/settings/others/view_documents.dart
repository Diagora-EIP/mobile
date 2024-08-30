import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';

class ViewDocuments extends StatefulWidget {
  const ViewDocuments({super.key});

  @override
  State<ViewDocuments> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  final ApiService _api = ApiService.getInstance();
  late List<dynamic> documents = [];
  late bool hasDocuments = false;
  late bool isLoading = false; // Add this variable

  void getDocuments() {
    setState(() {
      isLoading = true; // Start loading
    });

    _api.getDocuments().then((value) {
      print("Tester : " + value);

      // Decode JSON string to List<dynamic>
      try {
        var decodedValue = jsonDecode(value);

        setState(() {
          if (decodedValue.isEmpty) {
            hasDocuments = false;
          } else {
            documents = decodedValue;
            hasDocuments = true;
          }
          print(documents);
          print("Documents: " + documents.toString());
        });
      } catch (e) {
        print('Error decoding JSON: $e');
        setState(() {
          hasDocuments = false;
        });
      } finally {
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    }).catchError((error) {
      print('Error fetching documents: $error');
      setState(() {
        hasDocuments = false;
        isLoading = false; // Stop loading
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDocuments();
  }

  // Function to decode base64 string to Image
  Image _decodeBase64Image(String base64String) {
    final Uint8List bytes = base64Decode(base64String);
    return Image.memory(bytes, fit: BoxFit.contain);
  }

  // Function to show the image in a full-screen overlay
  void _showFullScreenImage(String base64String) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Set opaque to false to allow transparent background
        pageBuilder: (context, animation, secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Scaffold(
              backgroundColor:
                  Colors.black.withOpacity(0.7), // Semi-transparent background
              body: Center(
                child: GestureDetector(
                  onTap: () {
                    // Prevent popping when tapping on the image itself
                  },
                  child: _decodeBase64Image(base64String),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to show a dialog for editing document information
  void _showEditDialog(Map<String, dynamic> document) {
    final TextEditingController titleController =
        TextEditingController(text: document["title"] ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: document["description"] ?? '');
    final TextEditingController amountController =
        TextEditingController(text: document["amount"]?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Safely parse the amount to an integer
                int amount = int.tryParse(amountController.text) ?? 0;

                _updateDocument(
                  document["vehicle_id"] ?? 0,
                  titleController.text,
                  descriptionController.text,
                  amount,
                  document["picture"] ?? '',
                  document["vehicle_expense_id"] ?? 0,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update document information via API
  Future<void> _updateDocument(int vehicleId, String title, String description,
      int price, String picture, int documentId) async {
    bool success = await _api.updateDocument(
        vehicleId, title, description, price, picture, documentId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document updated successfully')),
      );
      // Refresh the documents list
      getDocuments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update document')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Documents'),
      ),
      body: isLoading // Show loading indicator while loading
          ? const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 10),
                  Text('Loading can take a while, please wait...')
                ]))
          : !hasDocuments
              ? const Center(
                  child: Text('No documents available'),
                )
              : SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      // Extract relevant details from each document object
                      final document = documents[index];
                      final title = document['title'] ?? 'No Title';
                      final description =
                          document['description'] ?? 'No Description';
                      final base64Image = document['picture'] ?? '';

                      return Card(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(description),
                          trailing: IconButton(
                            icon: const Icon(Icons.image),
                            onPressed: () {
                              if (base64Image.isNotEmpty) {
                                _showFullScreenImage(base64Image);
                              }
                            },
                          ),
                          onTap: () {
                            // Navigate to the edit dialog on tap
                            _showEditDialog(document);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
