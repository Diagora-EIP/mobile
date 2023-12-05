enum PermissionType {
  admin,
  manager,
  client,
  user,
}

/// Modèle de donnée pour les permissions d'un utilisateur.
class Permissions {
  final int id;
  final DateTime? createdAt;
  final bool isAdmin;
  final bool isUser;
  final bool isClient;
  final PermissionType? permissions;

  Permissions({
    this.id = -1,
    this.createdAt,
    this.isAdmin = false,
    this.isUser = false,
    this.isClient = false,
    this.permissions,
  });

  factory Permissions.fromJson(dynamic json) {
    Permissions permissions = Permissions(
      id: json['permission_id'] ?? -1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      isAdmin: json['isAdmin'] ?? false,
      isUser: json['isUser'] ?? false,
      isClient: false,
      permissions: _parsePermissionType(json['permissions']),
    );
    return permissions;
  }

  dynamic toJson() {
    return {
      'permission_id': id,
      'created_at': createdAt?.toIso8601String(),
      'isAdmin': isAdmin,
      'isUser': isUser,
      'isClient': isClient,
      'permissions': permissions?.toString().split('.').last,
    };
  }

  static PermissionType? _parsePermissionType(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'admin':
        return PermissionType.admin;
      case 'manager':
        return PermissionType.manager;
      case 'client':
        return PermissionType.client;
      case 'user':
        return PermissionType.user;
      default:
        return null; // Invalid value
    }
  }
}
