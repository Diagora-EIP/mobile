import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';

import 'package:diagora/models/user_model.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/company_model.dart';
import 'package:diagora/components/vehicles.dart';

class CompanyView extends StatefulWidget {
  final Company? company;

  const CompanyView({
    required this.company,
    Key? key,
  }) : super(key: key);

  @override
  CompanyViewState createState() => CompanyViewState();
}

class CompanyViewState extends State<CompanyView> {
  final ApiService _apiService = const ApiService();
  bool loading = false;
  late Company? _company;
  late List<int> userIds = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String creationDate = ''; // Final: "Company created the dd/mm/yyyy"
  String lastUpdateDate = ''; // Final: "Company updated the dd/mm/yyyy"

  bool isUserChecked(int id) {
    return userIds.contains(id);
  }

  void updateUserId(int id, bool checked) {
    if (checked) {
      userIds.add(id);
    } else {
      userIds.remove(id);
    }
  }

  void fetchCompany(int id) {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _apiService.fetchCompany(companyId: id).then((company) {
      if (company != null) {
        if (mounted) {
          setState(() {
            _company = company;
            _nameController.text = _company!.name ?? '';
            _addressController.text = _company!.address ?? '';
            if (_company!.createdAt != null) {
              creationDate = creationDate =
                  'Company created the ${_company!.createdAt!.day.toString().padLeft(2, '0')}/${_company!.createdAt!.month.toString().padLeft(2, '0')}/${_company!.createdAt!.year}';
            }
            if (_company!.updatedAt != null) {
              lastUpdateDate =
                  'Last updated the ${_company!.updatedAt!.day.toString().padLeft(2, '0')}/${_company!.updatedAt!.month.toString().padLeft(2, '0')}/${_company!.updatedAt!.year}';
            }
            loading = false;
          });
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occured while fetching the company.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      fetchCompany(widget.company!.id);
    } else {
      setState(() {
        loading = false;
        _company = null;
        _nameController.text = 'New company';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm(context) {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      userIds = userIds.toSet().toList();

      if (widget.company != null) {
        _apiService
            .patchCompany(
          widget.company!.id,
          _nameController.text,
          _addressController.text,
          userIds,
        )
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company updated.'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('An error occured while updating the company.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      } else {
        _apiService
            .createCompany(
          _nameController.text,
          _addressController.text,
          userIds,
        )
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company created.'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('An error occured while creating the company.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(loading
            ? 'Loading...'
            : (_company != null && _company!.name != null)
                ? _company!.name!
                : 'New company'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          loading == true ||
                  _nameController.text.isEmpty ||
                  _addressController.text.isEmpty
              ? const IconButton(
                  icon: Icon(Icons.check),
                  onPressed: null,
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _addressController.text.isNotEmpty) {
                      _submitForm(context);
                    }
                  },
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        enabled: loading ? false : true,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        enabled: loading ? false : true,
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Manage vehicules",
                            style: loading
                                ? const TextStyle(color: Colors.grey)
                                : null),
                        // Button to open schedules view
                        trailing: loading
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => VehiculesComponent(
                                        companyId: widget.company != null
                                            ? widget.company!.id
                                            : -1,
                                        pageTitle: "Manage company vehicules",
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                // if (creationDate.isNotEmpty) ...[
                //   Center(
                //     child: Text(
                //       creationDate,
                //       style: const TextStyle(color: Colors.grey),
                //     ),
                //   ),
                // ],
                // if (lastUpdateDate.isNotEmpty) ...[
                //   const SizedBox(height: 10),
                //   Center(
                //     child: Text(
                //       lastUpdateDate,
                //       style: const TextStyle(color: Colors.grey),
                //     ),
                //   ),
                // ],
                const SizedBox(height: 10),
                Accordion(
                  headerPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  disableScrolling: true,
                  scaleWhenAnimating: false,
                  openAndCloseAnimation: true,
                  contentBackgroundColor: backgroundColor,
                  children: [
                    AccordionSection(
                      contentVerticalPadding: 8,
                      leftIcon: const Icon(Icons.people, color: Colors.white),
                      header: const Text('Users in this company',
                          style: TextStyle(color: Colors.white)),
                      content: AccordionContent(
                        companyId:
                            widget.company != null ? widget.company!.id : -1,
                        isUserChecked: isUserChecked,
                        updateUserId: updateUserId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccordionContent extends StatefulWidget {
  final int companyId;
  final Function(int) isUserChecked;
  final Function(int, bool) updateUserId;

  const AccordionContent({
    Key? key,
    required this.companyId,
    required this.isUserChecked,
    required this.updateUserId,
  }) : super(key: key);

  @override
  AccordionContentState createState() => AccordionContentState();
}

class AccordionContentState extends State<AccordionContent> {
  final ApiService _apiService = const ApiService();
  bool loading = false;
  late List<User> users = [];
  late List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    if (mounted) {
      setState(() {
        loading = true;
      });
    } else {
      return;
    }
    _apiService.fetchUsers().then((users) {
      if (users != null) {
        if (mounted) {
          setState(() {
            this.users = users;
            this.users.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            // Keep only users in this company and without company
            this.users.removeWhere((user) =>
                user.company != null && user.company!.id != widget.companyId);
            filteredUsers = this.users;
            if (widget.companyId > 0) {
              for (User user in users) {
                if (user.company?.id == widget.companyId) {
                  widget.updateUserId(user.id, true);
                }
              }
            }
            loading = false;
          });
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occured while fetching users.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading == false) ...[
            if (users.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Set the background color for the TextField
                    filled: true,
                  ),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        filteredUsers = users
                            .where(
                              (user) =>
                                  user.name
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  user.email
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
                            )
                            .toList();
                      });
                    }
                  },
                ),
              ),
            ],
            if (filteredUsers.isEmpty) ...[
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'No user found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 60),
            ],
            for (User user in filteredUsers) ...[
              // If the user's name starts with a new character, a header row with the character is created
              if (users.indexOf(user) == 0 ||
                  user.name[0].toLowerCase() !=
                      users[users.indexOf(user) - 1].name[0].toLowerCase()) ...[
                if (users.indexOf(user) != 0) ...[
                  const SizedBox(height: 10),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
              const Divider(),
              ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                leading: // Avatar
                    CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    user.name.length == 1
                        ? user.name.toUpperCase()
                        : user.name[0].toUpperCase() +
                            user.name[1].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      if (widget.isUserChecked(user.id)) {
                        widget.updateUserId(user.id, false);
                      } else {
                        widget.updateUserId(user.id, true);
                      }
                    });
                  }
                },
                trailing: Checkbox(
                  value: widget.isUserChecked(user.id),
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        if (value == true) {
                          widget.updateUserId(user.id, true);
                        } else {
                          widget.updateUserId(user.id, false);
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 60),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }
}
