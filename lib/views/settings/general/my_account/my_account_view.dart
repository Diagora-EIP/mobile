import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/user_model.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({
    Key? key,
  }) : super(key: key);

  @override
  MyAccountViewState createState() => MyAccountViewState();
}

class MyAccountViewState extends State<MyAccountView> {
  final ApiService _apiService = const ApiService();
  late User _user;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String creationDate = ''; // Final: "Account created the dd/mm/yyyy"

  void fetchCurrentUser() {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _apiService.fetchUser().then((user) {
      if (user != null) {
        if (mounted) {
          setState(() {
            loading = false;
            _user = user;
            _nameController.text = user.name;
            _emailController.text = user.email;
            if (user.createdAt != null) {
              creationDate =
                  'Account created the ${user.createdAt!.day.toString().padLeft(2, '0')}/${user.createdAt!.month.toString().padLeft(2, '0')}/${user.createdAt!.year}';
            }
          });
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

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          Navigator.of(context).pop(true);
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
        title: Text(loading ? 'Loading...' : 'My account'),
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
