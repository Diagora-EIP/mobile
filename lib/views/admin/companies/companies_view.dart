import 'package:diagora/views/admin/companies/company/company_view.dart';
import 'package:flutter/material.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/models/company_model.dart';

class CompaniesView extends StatefulWidget {
  const CompaniesView({
    Key? key,
  }) : super(key: key);

  @override
  CompaniesViewState createState() => CompaniesViewState();
}

class CompaniesViewState extends State<CompaniesView> {
  final ApiService _apiService = const ApiService();
  List<Company> companies = [];
  List<Company> filteredCompanies = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  void fetchCompanies() {
    setState(() {
      loading = true;
    });
    _apiService.fetchCompanies().then((companies) {
      if (companies != null) {
        setState(() {
          this.companies = companies;
          this.companies.sort((a, b) => a.name!.compareTo(b.name!));
          filteredCompanies = this.companies;
          loading = false;
        });
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occured while fetching companies.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        actions: <Widget>[
          loading == true // Add button
              ? const IconButton(
                  icon: Icon(Icons.add),
                  onPressed: null,
                )
              : IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyView(company: null),
                      ),
                    );
                  },
                ),
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading == false) ...[
                if (companies.isNotEmpty) ...[
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
                          filteredCompanies = companies
                              .where(
                                (company) =>
                                    (company.name != null && company.name!
                                        .toLowerCase()
                                        .contains(value.toLowerCase())) ||
                                    (company.address != null && company.address!
                                        .toLowerCase()
                                        .contains(value.toLowerCase())),
                              )
                              .toList();
                        });
                      },
                    ),
                  ),
                ],
                if (filteredCompanies.isEmpty) ...[
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      'No company found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
                for (Company company in filteredCompanies) ...[
                  // If the company's name starts with a new character, a header row with the character is created
                  if (companies.indexOf(company) == 0 ||
                      (company.name != null && company.name?[0] != companies[companies.indexOf(company) - 1].name?[0])) ...[
                    if (companies.indexOf(company) != 0) ...[
                      const SizedBox(height: 10),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Text(
                          company.name?[0].toUpperCase() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                      title: Text(company.name ?? 'Unknown'),
                      subtitle: null, // Text(company.address ?? ''),
                      leading: // Avatar
                          CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text(
                          company.name != null && company.name?.length == 1
                              ? company.name == null ? "U" : company.name!.toUpperCase()
                              : company.name == null ? "" : company.name![0].toUpperCase() + company.name![1].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyView(company: company),
                          ),
                        );
                      }),
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
    );
  }
}
