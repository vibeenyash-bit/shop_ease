import 'cart_item.dart';

/// pending   = saved on this phone, not yet sent to the server.
/// confirmed = the server has the order.
enum OrderStatus { pending, confirmed }

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.error,
  });

  /// Generated once on the phone. Also used as the server document id,
  /// so sending the same order twice never creates a duplicate.
  final String id;
  final String userId;
  final List<CartItem> items;
  final String name;
  final String phone;
  final String address;
  final String pincode;
  final DateTime createdAt;
  OrderStatus status;

  /// Last sync error, shown on pending orders.
  String? error;

  int get total => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        userId: json['userId'] as String,
        items: (json['items'] as List)
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        pincode: json['pincode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: json['status'] == 'confirmed'
            ? OrderStatus.confirmed
            : OrderStatus.pending,
        error: json['error'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((e) => e.toJson()).toList(),
        'name': name,
        'phone': phone,
        'address': address,
        'pincode': pincode,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'error': error,
      };
}
