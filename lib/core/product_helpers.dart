import '../models/product.dart';

Product productFromDisplayData({
  required String title,
  required String description,
  required String price,
  required String imagePath,
}) {
  return Product(
    id: title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
    name: title,
    description: description,
    price: priceToDouble(price),
    imageUrl: imagePath,
  );
}

double priceToDouble(String price) {
  return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
}

String formatPrice(double price) {
  final hasCents = price % 1 != 0;
  return '\$${price.toStringAsFixed(hasCents ? 2 : 0)}';
}
