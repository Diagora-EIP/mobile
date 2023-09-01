import 'package:diagora/models/permissions_model.dart';
import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/user_model.dart';

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
  late Permissions? _permissions;
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
    _apiService.fetchPermissions(userId: id).then((permissions) {
      if (mounted) {
        setState(() {
          loading = false;
          _permissions = permissions;
          _nameController.text = _user.name;
          _emailController.text = _user.email;
          _permissionController.text =
              _permissions?.permissions.toString() ?? 'null';
          if (_user.createdAt != null) {
            creationDate =
                'Account created the ${_user.createdAt!.day.toString().padLeft(2, '0')}/${_user.createdAt!.month.toString().padLeft(2, '0')}/${_user.createdAt!.year}';
          }
        });
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
      _apiService.patchUser(_user).then((succeed) {
        if (succeed) {
          if (_permissions == null) {
            Navigator.of(context).pop(true);
          } else {
            String? newPermission;
            switch (_permissionController.text) {
              case 'PermissionType.admin':
                newPermission = 'admin';
                break;
              case 'PermissionType.manager':
                newPermission = 'manager';
                break;
              case 'PermissionType.user':
                newPermission = 'user';
                break;
              default:
                newPermission = null;
                break;
            }
            dynamic data = _permissions?.toJson();
            data['permissions'] = newPermission;
            _apiService
                .patchPermissions(Permissions.fromJson(data),
                    userId: _permissions?.id)
                .then((succeed) {
              if (succeed) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'An error occured while saving your account permissions.'),
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occured while saving your account.'),
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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Role",
                            style: loading || _permissions == null
                                ? const TextStyle(color: Colors.grey)
                                : null),
                        trailing: DropdownButton(
                          value: _permissionController.text,
                          items: const [
                            DropdownMenuItem(
                              value: 'PermissionType.admin',
                              child: Text('Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'PermissionType.manager',
                              child: Text('Manager'),
                            ),
                            DropdownMenuItem(
                              value: 'PermissionType.user',
                              child: Text('User'),
                            ),
                            DropdownMenuItem(
                              value: 'null',
                              child: Text('Undefined'),
                            ),
                          ],
                          onChanged: loading || _permissions == null
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  if (mounted) {
                                    if (mounted) {
                                      setState(() {
                                        _permissionController.text =
                                            value.toString();
                                      });
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                if (creationDate.isNotEmpty) ...[
                  Center(
                    child: Text(
                      creationDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
