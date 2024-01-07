/// Modèle de données pour une commande.
class Order {
  int id;
  DateTime? orderDate;
  String? deliveryAddress;
  DateTime createdAt;
  DateTime updatedAt;
  String? description;
  int? companyId;

  Order({
    this.id = -1,
    this.orderDate,
    this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    required this.companyId,
  });

  factory Order.fromJson(dynamic json) {
    Order order = Order(
      id: json['order_id'] ?? json['id'] ?? -1,
      orderDate: json['order_date'] != null ? DateTime.parse(json['order_date']) : null,
      deliveryAddress: json['delivery_address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime(0).toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime(0).toString()),
      description: json['description'] ?? '',
      companyId: json['company_id'],
    );
    return order;
  }

  dynamic toJson() {
    return {
      'order_id': id,
      'order_date': orderDate?.toIso8601String(),
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'description': description,
      'company_id': companyId,
    };
  }
}
