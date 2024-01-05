import 'package:diagora/models/company_model.dart';

/// Modèle de données pour un utilisateur.
class User {
  int id;
  String email;
  String name;
  String encryptedPassword;
  DateTime? createdAt;
  String? resetPassword;
  Company? company;
  int? companyId;

  User({
    this.id = -1,
    this.email = '',
    this.name = '',
    this.encryptedPassword = '',
    this.createdAt,
    this.resetPassword = '',
    this.company,
    this.companyId,
  });

  factory User.fromJson(dynamic json) {
    User user = User(
      id: json['user_id'] ?? json['id'] ?? -1,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      encryptedPassword: json['password'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      resetPassword: json['reset-password'] ?? '',
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      companyId: json['company_id'] ?? -1,
    );
    return user;
  }

  dynamic toJson() {
    return {
      'user_id': id,
      'email': email,
      'name': name,
      'password': encryptedPassword,
      'created_at': createdAt?.toIso8601String(),
      'reset-password': resetPassword,
      'company_id': companyId == -1 ? null : companyId,
    };
  }
}
