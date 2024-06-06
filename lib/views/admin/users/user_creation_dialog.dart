import 'package:flutter/material.dart';
import 'package:diagora/models/role_model.dart';
import 'package:diagora/models/company_model.dart';
import 'package:diagora/services/api_service.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class UserCreationDialog extends StatefulWidget {
  final void Function(
      String email, String name, List<Role> roles, Company company) onCreate;

  const UserCreationDialog({required this.onCreate, Key? key})
      : super(key: key);

  @override
  _UserCreationDialogState createState() => _UserCreationDialogState();
}

class _UserCreationDialogState extends State<UserCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  List<Company> _companies = [];
  Company? _selectedCompany;
  List<Role> _selectedRoles = [];
  final List<Roles> _roles = [
    Roles.admin,
    Roles.manager,
    Roles.client,
    Roles.user,
    Roles.livreur,
  ];

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  void _fetchCompanies() async {
    List<Company>? companies = await ApiService().fetchCompanies();
    setState(() {
      _companies = companies ?? [];
      if (_companies.isNotEmpty) {
        _selectedCompany = _companies.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Company>(
                decoration: const InputDecoration(labelText: 'Company'),
                value: _selectedCompany,
                items: _companies.map((Company company) {
                  return DropdownMenuItem<Company>(
                    value: company,
                    child: Text(company.name ?? ''),
                  );
                }).toList(),
                onChanged: (Company? newValue) {
                  setState(() {
                    _selectedCompany = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a company';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MultiSelectDialogField<Roles>(
                items: Roles.values
                    .map((role) => MultiSelectItem<Roles>(
                        role, role.toString().split('.').last))
                    .toList(),
                title: const Text("Roles"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                buttonText: const Text(
                  "Select Roles",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    _selectedRoles = results.map((role) {
                      return Role(role: role);
                    }).toList();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedCompany != null) {
              String email = _emailController.text;
              String name = _nameController.text;

              widget.onCreate(email, name, _selectedRoles, _selectedCompany!);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
