class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
  });

  final String id;
  final String name;
  final String category;

  /// Price in Indian Rupees.
  final int price;
  final String image;
  final String description;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? '',
        price: (json['price'] as num).toInt(),
        image: json['image'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'image': image,
        'description': description,
      };
}
