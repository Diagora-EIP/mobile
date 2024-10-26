import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:diagora/services/api_service.dart';

class NewDocument extends StatefulWidget {
  const NewDocument({super.key});

  @override
  State<NewDocument> createState() => _NewDocumentState();
}

class _NewDocumentState extends State<NewDocument> {
  final ApiService _api = ApiService.getInstance();

  String title = '';
  String price = '0';
  File? _image;
  int _selectedCategory = 0;
  DateTime? _selectedDate;
  dynamic myVehicleData;
  int? _selectedVehicleId; // To store the selected vehicle ID
  List<dynamic> allVehicles = []; // List to store all vehicles
  dynamic userId;
  bool isLoading = false;

  final double _kItemExtent = 32.0;
  final List<String> _categoriesNames = <String>[
    'Invoice',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    userId = _api.user?.toJson()['user_id'];

    _api.getUserVehicle(userId).then((value) {
      // Retrieve the list of all vehicles
      _api.getAllUserVehicles().then((vehicles) {
        setState(() {
          allVehicles = vehicles;
        });
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void _selectDate() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          child: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate ?? DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> submitNewDocument({
    required String title,
    required int price,
    required File image,
    required int vehicleId,
    required String category,
    required DateTime date,
  }) async {
    String imageBase64 = base64Encode(image.readAsBytesSync());
    bool returnValue = false;

    setState(() {
      isLoading = true;
    });
    returnValue = await _api.registerNewDocument(
        vehicleId, title, category, price, imageBase64,
        userId: userId);

    return returnValue;
  }

  void _selectCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          child: SizedBox(
            height: 200,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: _kItemExtent,
              scrollController: FixedExtentScrollController(
                initialItem: _selectedCategory,
              ),
              onSelectedItemChanged: (int selectedItem) {
                setState(() {
                  _selectedCategory = selectedItem;
                });
              },
              children:
                  List<Widget>.generate(_categoriesNames.length, (int index) {
                return Center(child: Text(_categoriesNames[index]));
              }),
            ),
          ),
        );
      },
    );
  }

  void showAlertError() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: const Text('Please fill all fields'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Document'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name of the document',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text('Choose Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text('Format: MM.dd.yyyy'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                _selectDate();
                              },
                              child: Container(
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CupertinoButton(
                                      onPressed: () {
                                        _selectDate();
                                      },
                                      child: Text(
                                        _selectedDate != null
                                            ? DateFormat('MM.dd.yyyy')
                                                .format(_selectedDate!)
                                            : 'Select a Date',
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text('Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('in euros')),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                              width: 120,
                              child: TextFormField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    price = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Select Vehicle',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      value: _selectedVehicleId,
                      items: allVehicles
                          .map<DropdownMenuItem<int>>((vehicle) =>
                              DropdownMenuItem<int>(
                                  value: vehicle['vehicle_id'],
                                  child: Text(vehicle['name'])))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleId = value;
                        });
                      },
                    ),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 8.0),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _selectCategory();
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                                child: Text(
                                  _categoriesNames[_selectedCategory],
                                ),
                                onPressed: () {
                                  _selectCategory();
                                }),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_image == null) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Icons.file_upload_outlined,
                                  size: 50,
                                ),
                                const Text('Upload Document'),
                                CupertinoButton(
                                  color: Colors.grey,
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ImageSourcePicker(
                                          onImageSourceSelected: (source) {
                                            _pickImage(source);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Upload'),
                                ),
                              ])),
                    )
                  ],
                  if (_image != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ImageSourcePicker(
                                      onImageSourceSelected: (source) {
                                        _pickImage(source);
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text('Upload another document'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.file(
                              _image!,
                              height: 200,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (title.isEmpty ||
                              _image == null ||
                              price.isEmpty ||
                              _selectedDate == null) {
                            showAlertError();
                            return;
                          }
                          bool returnValue = await submitNewDocument(
                            title: title,
                            price: price.isEmpty ? 0 : int.parse(price),
                            image: _image!,
                            vehicleId: _selectedVehicleId!,
                            category: _categoriesNames[_selectedCategory],
                            date: _selectedDate!,
                          );
                          setState(() {
                            isLoading = false;
                          });
                          if (returnValue) {
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          } else {
                            showAlertError();
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                color: Colors.transparent,
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageSourcePicker extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourcePicker({Key? key, required this.onImageSourceSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        'Select Image Source',
        textAlign: TextAlign.center,
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          child: const Text('Gallery'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.camera);
            Navigator.of(context).pop();
          },
          child: const Text('Camera'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
    );
  }
}
