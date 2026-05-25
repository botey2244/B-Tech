import '../models/product.dart';

Product productFromDisplayData({
  required String title,
  required String description,
  required String price,
  required String imagePath,
  String brand = 'Generic',
  String category = 'Other',
}) {
  return Product(
    id: title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
    name: title,
    brand: brand,
    category: category,
    description: description,
    price: priceToDouble(price),
    imageUrl: imagePath,
  );
}

double priceToDouble(String price) {
  return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
}

String formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return '\$${price.toStringAsFixed(0)}';
  }
  return '\$${price.toStringAsFixed(2)}';
}
