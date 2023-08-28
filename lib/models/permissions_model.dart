/// Modèle de donnée pour les permissions d'un utilisateur.
class Permissions {
  final int id;
  final DateTime? createdAt;
  final bool isAdmin;
  final bool isUser;
  final dynamic
      permissions; // TODO: Connaître le type de la variable, nous reçevons null lors des tests

  Permissions({
    this.id = -1,
    this.createdAt,
    this.isAdmin = false,
    this.isUser = false,
    this.permissions = '',
  });

  factory Permissions.fromJson(dynamic json) {
    Permissions permissions = Permissions(
      id: json['permission_id'] ?? -1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      isAdmin: json['isAdmin'] ?? false,
      isUser: json['isUser'] ?? false,
      permissions: json['permissions'],
    );
    return permissions;
  }

  dynamic toJson() {
    return {
      'permission_id': id,
      'created_at': createdAt?.toIso8601String(),
      'isAdmin': isAdmin,
      'isUser': isUser,
      'permissions': permissions,
    };
  }
}
