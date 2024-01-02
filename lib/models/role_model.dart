enum Roles {
  admin,
  manager,
  client,
  user,
}

/// Modèle de donnée pour les permissions d'un utilisateur.
class Role {
  final int id;
  final Roles? role;
  final String description;

  Role({
    this.id = -1,
    this.role = Roles.user,
    this.description = '',
  });

  factory Role.fromJson(dynamic json) {
    Role role = Role(
      id: json['role_id'] ?? -1,
      role: _getRoleType(json['name']),
      description: json['description'] ?? '',
    );
    return role;
  }

  dynamic toJson() {
    return {
      'permission_id': id,
      'name': role.toString(),
      'description': description,
    };
  }

  static Roles? _getRoleType(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'admin':
        return Roles.admin;
      case 'manager':
        return Roles.manager;
      case 'client':
        return Roles.client;
      case 'user':
        return Roles.user;
      default:
        return null; // Invalid value
    }
  }
}
