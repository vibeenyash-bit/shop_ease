import 'product.dart';

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;

  int get total => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };
}
