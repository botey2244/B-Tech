import 'package:firebase_database/firebase_database.dart';

import '../models/product.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<Product>> fetchProducts() async {
    await seedDefaultProductsIfEmpty();
    final snapshot = await _database.ref('products').get();
    final value = snapshot.value;
    if (value is! Map) return [];

    return value.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      return Product.fromJson(data, entry.key.toString());
    }).toList();
  }

  Future<void> seedDefaultProductsIfEmpty() async {
    final productsRef = _database.ref('products');
    final snapshot = await productsRef.limitToFirst(1).get();
    if (snapshot.exists) return;

    final products = [
      Product(
        id: 'apple-macbook-m1',
        name: 'Apple MacBook M1',
        description: 'Powerful, sleek, and portable laptop.',
        price: 1299,
        imageUrl: 'assets/images/image.png',
      ),
      Product(
        id: 'dell-inspiron-all-in-one',
        name: 'Dell Inspiron All-in-One',
        description: 'All-in-one desktop with sleek design.',
        price: 1099,
        imageUrl: 'assets/images/image.png',
      ),
      Product(
        id: 'noise-cancelling-headphones',
        name: 'Noise-Cancelling Headphones',
        description: 'Clear audio with plush memory.',
        price: 149.99,
        imageUrl: 'assets/images/image.png',
      ),
      Product(
        id: 'lenovo-ideapad-slim-3',
        name: 'Lenovo IdeaPad Slim 3',
        description: 'Reliable performance for everyday tasks.',
        price: 499.99,
        imageUrl: 'assets/images/image.png',
      ),
      Product(
        id: 'gaming-monitor',
        name: 'Gaming Monitor',
        description: 'Sharp display with smooth refresh rate.',
        price: 229.99,
        imageUrl: 'assets/images/image.png',
      ),
      Product(
        id: 'wireless-keyboard',
        name: 'Wireless Keyboard',
        description: 'Compact typing for work and study.',
        price: 59.99,
        imageUrl: 'assets/images/image.png',
      ),
    ];

    final updates = <String, Object?>{};
    for (final product in products) {
      updates[product.id] = product.toJson();
    }
    await productsRef.update(updates);
  }

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final snapshot = await _database.ref('users/$uid/profile').get();
    final value = snapshot.value;
    if (value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> profile,
  ) async {
    await _database.ref('users/$uid/profile').update({
      ...profile,
      'updatedAt': ServerValue.timestamp,
    });
  }
}
