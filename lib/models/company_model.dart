/// Modèle de données pour une entreprise.
class Company {
  int id;
  DateTime? createdAt;
  String? name;
  DateTime? updatedAt;
  String? address;

  Company({
    this.id = -1,
    this.createdAt,
    this.name,
    this.updatedAt,
    this.address,
  });

  factory Company.fromJson(dynamic json) {
    Company company = Company(
      id: json['company_id'] ?? json['id'] ?? -1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      address: json['address'] ?? '',
    );
    return company;
  }

  dynamic toJson() {
    return {
      'company_id': id,
      'created_at': createdAt?.toIso8601String(),
      'name': name,
      'updated_at': updatedAt?.toIso8601String(),
      'address': address,
    };
  }
}
