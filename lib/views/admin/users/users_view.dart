import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/user_model.dart';
import 'package:diagora/views/admin/users/user/user_view.dart';
import 'package:diagora/models/role_model.dart';
import 'package:diagora/models/company_model.dart';
import 'package:diagora/views/admin/users/user_creation_dialog.dart';

class UsersView extends StatefulWidget {
  const UsersView({
    Key? key,
  }) : super(key: key);

  @override
  UsersViewState createState() => UsersViewState();
}

class UsersViewState extends State<UsersView> {
  final ApiService _apiService = const ApiService();
  List<User> users = [];
  List<User> filteredUsers = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    setState(() {
      loading = true;
    });
    _apiService.fetchUsers().then((users) {
      if (users != null) {
        setState(() {
          this.users = users;
          this.users.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          filteredUsers = this.users;
          loading = false;
        });
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while fetching users.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void deleteUser(User user) {
    setState(() {
      users.remove(user);
      filteredUsers.remove(user);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} has been deleted.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void createUser(
      String email, String name, List<Role> roles, Company company) {
    _apiService.createAdminUser(email, name, roles, company).then((_) {
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!loading) ...[
                if (users.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
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
                ],
                for (User user in filteredUsers) ...[
                  if (users.indexOf(user) == 0 ||
                      user.name[0].toLowerCase() !=
                          users[users.indexOf(user) - 1]
                              .name[0]
                              .toLowerCase()) ...[
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
                  Dismissible(
                    key: Key(
                        user.id.toString()), // assuming User has a unique id
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      deleteUser(user);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      leading: CircleAvatar(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserView(user: user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 60),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return UserCreationDialog(
                onCreate: createUser,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
