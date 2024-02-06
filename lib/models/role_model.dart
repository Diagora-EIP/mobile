enum Roles {
  admin,
  manager,
  livreur,
  user,
  client
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
      'name': _getRoleName(role),
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
      case 'livreur':
        return Roles.livreur;
      default:
        return null; // Invalid value
    }
  }

  static String _getRoleName(Roles? role) {
    if (role == null) return '';
    switch (role) {
      case Roles.admin:
        return 'admin';
      case Roles.manager:
        return 'manager';
      case Roles.client:
        return 'client';
      case Roles.user:
        return 'user';
      case Roles.livreur:
        return 'livreur';
      default:
        return ''; // Invalid value
    }
  }

}
