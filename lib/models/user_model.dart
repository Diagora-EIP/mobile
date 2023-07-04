/// Modèle de données pour un utilisateur.
class User {
  final int id;
  final String email;
  final String name;
  final String encryptedPassword;
  final DateTime? createdAt;

  User({
    this.id = -1,
    this.email = '',
    this.name = '',
    this.encryptedPassword = '',
    this.createdAt,
  });

  factory User.fromJson(dynamic json) {
    User user = User(
      id: json['user_id'] ?? json['id'] ?? -1,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      encryptedPassword: json['password'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
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
    };
  }

  int getUserId() {
    return id;
  }
}
