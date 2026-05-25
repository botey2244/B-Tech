class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int soldCount;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 4.6,
    this.reviewCount = 100,
    this.soldCount = 50,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/image.png',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.6,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 100,
      soldCount: (json['soldCount'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'soldCount': soldCount,
    };
  }
}
