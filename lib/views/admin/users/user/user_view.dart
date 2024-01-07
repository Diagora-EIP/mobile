import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';

// import 'package:diagora/views/admin/users/user/schedules/shedules_view.dart';
// import 'package:diagora/components/vehicules.dart';

import 'package:diagora/models/user_model.dart';
import 'package:diagora/models/role_model.dart';
import 'package:diagora/models/company_model.dart';

class UserView extends StatefulWidget {
  final User user;

  const UserView({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  UserViewState createState() => UserViewState();
}

class UserViewState extends State<UserView> {
  final ApiService _apiService = const ApiService();
  late User _user;
  late Role? _role;
  Company? _company;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _permissionController = TextEditingController(text: 'null');
  String creationDate = ''; // Final: "Account created the dd/mm/yyyy"

  void fetchUser(int id) {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _apiService.fetchUser(userId: id).then((user) {
      if (user != null) {
        if (mounted) {
          setState(() {
            _user = user;
          });
          fetchUserPermissions(id);
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occured while fetching your account.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void fetchUserPermissions(int id) {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _apiService.fetchRoles(userId: id).then((permissions) {
      if (mounted) {
        setState(() {
          if (_user.companyId != null && _user.companyId != -1) {
            fetchUserCompany(_user.companyId!);
          } else {
            loading = false;
          }
          _role = permissions;
          _nameController.text = _user.name;
          _emailController.text = _user.email;
          _permissionController.text = _role?.role.toString() ?? 'null';
          if (_role?.role == Roles.admin) {
            _permissionController.text = 'PermissionType.admin';
          }
          // else if (_role?.isManager == true) {
          //   _permissionController.text = 'PermissionType.manager';
          // }
          else if (_role?.role == Roles.user) {
            _permissionController.text = 'PermissionType.user';
          } else {
            _permissionController.text = 'null';
          }
          if (_user.createdAt != null) {
            creationDate =
                'Account created the ${_user.createdAt!.day.toString().padLeft(2, '0')}/${_user.createdAt!.month.toString().padLeft(2, '0')}/${_user.createdAt!.year}';
          }
        });
      }
    });
  }

  void fetchUserCompany(int id) {
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
    fetchUser(widget.user.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _permissionController.dispose();
    super.dispose();
  }

  void _submitForm(context) {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      _user.name = _nameController.text;
      _apiService.patchUser(_user, userId: _user.id).then((succeed) {
        if (succeed) {
          if (mounted) {
            setState(() {
              widget.user.name = _user.name;
            });
          }
          Navigator.of(context).pop(true);
          // if (_role == null) {
          //   Navigator.of(context).pop(true);
          // } else {
          //   String? newPermission;
          //   switch (_permissionController.text) {
          //     case 'PermissionType.admin':
          //       newPermission = 'admin';
          //       break;
          //     case 'PermissionType.manager':
          //       newPermission = 'manager';
          //       break;
          //     case 'PermissionType.user':
          //       newPermission = 'user';
          //       break;
          //     default:
          //       newPermission = null;
          //       break;
          //   }
          //   dynamic data = {
          //     "role": "user",
          //   };
          //   data['permissions'] = newPermission;
          //   switch (data['permissions']) {
          //     case 'admin':
          //       data["role"] = "admin";
          //       break;
          //     case 'manager':
          //       data["role"] = "manager";
          //       break;
          //     case 'user':
          //       data["role"] = "user";
          //       break;
          //   }
          //   _apiService
          //       .patchRoles(data["role"], userId: _user.id)
          //       .then((succeed) {
          //     if (succeed) {
          //       Navigator.of(context).pop(true);
          //     } else {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text(
          //               'An error occured while saving account permissions.'),
          //           duration: Duration(seconds: 2),
          //         ),
          //       );
          //       if (mounted) {
          //         setState(() {
          //           loading = false;
          //         });
          //       }
          //     }
          //   });
          // }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occured while saving account.'),
              duration: Duration(seconds: 2),
            ),
          );
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loading ? 'Loading...' : _user.email),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          loading == true
              ? const IconButton(
                  icon: Icon(Icons.check),
                  onPressed: null,
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    _submitForm(context);
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
                          labelText: 'Full name',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        enabled: false,
                        controller: _emailController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Select field with options "Admin" (admin) and "User" (user)
                      // ListTile(
                      //   contentPadding: EdgeInsets.zero,
                      //   title: Text("Role",
                      //       style: loading || _role == null
                      //           ? const TextStyle(color: Colors.grey)
                      //           : null),
                      //   trailing: DropdownButton(
                      //     value: _permissionController.text,
                      //     items: const [
                      //       DropdownMenuItem(
                      //         value: 'PermissionType.admin',
                      //         child: Text('Admin'),
                      //       ),
                      //       // DropdownMenuItem(
                      //       //   value: 'PermissionType.manager',
                      //       //   child: Text('Manager'),
                      //       // ),
                      //       DropdownMenuItem(
                      //         value: 'PermissionType.user',
                      //         child: Text('User'),
                      //       ),
                      //       DropdownMenuItem(
                      //         value: 'null',
                      //         child: Text('Undefined'),
                      //       ),
                      //     ],
                      //     onChanged: loading || _role == null
                      //         ? null
                      //         : (value) {
                      //             if (value == null) return;
                      //             if (mounted) {
                      //               if (mounted) {
                      //                 setState(() {
                      //                   _permissionController.text =
                      //                       value.toString();
                      //                 });
                      //               }
                      //             }
                      //           },
                      //   ),
                      // ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Company",
                            style: loading || _company == null
                                ? const TextStyle(color: Colors.grey)
                                : null),
                        trailing: Text(
                          _company?.name ?? 'None',
                          style: loading || _company == null
                              ? const TextStyle(color: Colors.grey)
                              : null,
                        ),
                      ),
                      // ListTile(
                      //   contentPadding: EdgeInsets.zero,
                      //   title: Text("Manage calendar",
                      //       style: loading
                      //           ? const TextStyle(color: Colors.grey)
                      //           : null),
                      //   // Button to open schedules view
                      //   trailing: loading
                      //       ? null
                      //       : IconButton(
                      //           icon: const Icon(Icons.arrow_forward_ios),
                      //           onPressed: () {
                      //             Navigator.of(context).push(
                      //               MaterialPageRoute(
                      //                 builder: (context) =>
                      //                     SchedulesView(_user.id),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      // ),
                      // ListTile(
                      //   contentPadding: EdgeInsets.zero,
                      //   title: Text("Manage vehicules",
                      //       style: loading
                      //           ? const TextStyle(color: Colors.grey)
                      //           : null),
                      //   // Button to open schedules view
                      //   trailing: loading
                      //       ? null
                      //       : IconButton(
                      //           icon: const Icon(Icons.arrow_forward_ios),
                      //           onPressed: () {
                      //             Navigator.of(context).push(
                      //               MaterialPageRoute(
                      //                 builder: (context) => VehiculesComponent(
                      //                   userId: _user.id,
                      //                   pageTitle: "Manage vehicules",
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      // ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
