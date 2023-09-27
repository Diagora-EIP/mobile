/// Modèle de données pour un utilisateur.
class User {
  int id;
  String email;
  String name;
  String encryptedPassword;
  DateTime? createdAt;
  String? resetPassword;

  User({
    this.id = -1,
    this.email = '',
    this.name = '',
    this.encryptedPassword = '',
    this.createdAt,
    this.resetPassword = '',
  });

  factory User.fromJson(dynamic json) {
    User user = User(
      id: json['user_id'] ?? json['id'] ?? -1,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      encryptedPassword: json['password'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      resetPassword: json['reset-password'] ?? '',
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
    };
  }
}
