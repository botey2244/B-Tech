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

    final products = <Product>[
      Product(
          id: 'macbook-m1',
          name: 'MacBook M1',
          brand: 'Apple',
          category: 'Laptops',
          description: 'Sleek and powerful laptop.',
          price: 1299,
          imageUrl: 'assets/images/image1.png',
          rating: 4.8,
          reviewCount: 1068,
          soldCount: 240),
      Product(
          id: 'lenovo-ideapad',
          name: 'Lenovo IdeaPad',
          brand: 'Lenovo',
          category: 'Laptops',
          description: 'Lightweight laptop.',
          price: 599,
          imageUrl: 'assets/images/image2.png',
          rating: 4.5,
          reviewCount: 320,
          soldCount: 120),
      Product(
          id: 'dell-xps-13',
          name: 'Dell XPS 13',
          brand: 'Dell',
          category: 'Laptops',
          description: 'Compact ultrabook.',
          price: 1099,
          imageUrl: 'assets/images/image3.png',
          rating: 4.7,
          reviewCount: 540,
          soldCount: 180),
      Product(
          id: 'hp-pavilion-laptop',
          name: 'HP Pavilion',
          brand: 'HP',
          category: 'Laptops',
          description: 'Reliable daily laptop.',
          price: 699,
          imageUrl: 'assets/images/image4.png',
          rating: 4.4,
          reviewCount: 210,
          soldCount: 95),
      Product(
          id: 'asus-zenbook',
          name: 'Asus ZenBook',
          brand: 'Asus',
          category: 'Laptops',
          description: 'Thin and fast laptop.',
          price: 899,
          imageUrl: 'assets/images/image5.png',
          rating: 4.6,
          reviewCount: 410,
          soldCount: 130),
      Product(
          id: 'acer-swift-3',
          name: 'Acer Swift 3',
          brand: 'Acer',
          category: 'Laptops',
          description: 'Budget-friendly laptop.',
          price: 549,
          imageUrl: 'assets/images/image6.png',
          rating: 4.3,
          reviewCount: 180,
          soldCount: 88),
      Product(
          id: 'dell-inspiron-aio',
          name: 'Dell Inspiron AIO',
          brand: 'Dell',
          category: 'Desktops',
          description: 'All-in-one PC.',
          price: 1099,
          imageUrl: 'assets/images/image7.png',
          rating: 4.6,
          reviewCount: 330,
          soldCount: 100),
      Product(
          id: 'hp-pavilion-desktop',
          name: 'HP Pavilion Desktop',
          brand: 'HP',
          category: 'Desktops',
          description: 'Reliable desktop.',
          price: 799,
          imageUrl: 'assets/images/image8.png',
          rating: 4.4,
          reviewCount: 210,
          soldCount: 90),
      Product(
          id: 'lenovo-ideacentre',
          name: 'Lenovo IdeaCentre',
          brand: 'Lenovo',
          category: 'Desktops',
          description: 'Compact all-in-one.',
          price: 999,
          imageUrl: 'assets/images/image9.png',
          rating: 4.5,
          reviewCount: 260,
          soldCount: 110),
      Product(
          id: 'apple-imac',
          name: 'Apple iMac',
          brand: 'Apple',
          category: 'Desktops',
          description: 'Premium desktop.',
          price: 1299,
          imageUrl: 'assets/images/image10.png',
          rating: 4.8,
          reviewCount: 800,
          soldCount: 220),
      Product(
          id: 'dell-optiplex',
          name: 'Dell OptiPlex',
          brand: 'Dell',
          category: 'Desktops',
          description: 'Business desktop.',
          price: 1199,
          imageUrl: 'assets/images/image11.png',
          rating: 4.7,
          reviewCount: 430,
          soldCount: 160),
      Product(
          id: 'hp-aio-22',
          name: 'HP AIO 22-inch',
          brand: 'HP',
          category: 'Desktops',
          description: 'Affordable all-in-one.',
          price: 699,
          imageUrl: 'assets/images/image12.png',
          rating: 4.3,
          reviewCount: 190,
          soldCount: 80),
      Product(
          id: 'dell-ultrasharp-27',
          name: 'Dell UltraSharp 27"',
          brand: 'Dell',
          category: 'Monitors',
          description: 'High-res monitor.',
          price: 399,
          imageUrl: 'assets/images/image13.png',
          rating: 4.7,
          reviewCount: 520,
          soldCount: 170),
      Product(
          id: 'lg-24-monitor',
          name: 'LG 24"',
          brand: 'LG',
          category: 'Monitors',
          description: 'Full HD display.',
          price: 149,
          imageUrl: 'assets/images/image14.png',
          rating: 4.4,
          reviewCount: 260,
          soldCount: 140),
      Product(
          id: 'asus-proart-27',
          name: 'Asus ProArt 27"',
          brand: 'Asus',
          category: 'Monitors',
          description: 'Color-accurate monitor.',
          price: 499,
          imageUrl: 'assets/images/image15.png',
          rating: 4.8,
          reviewCount: 350,
          soldCount: 120),
      Product(
          id: 'samsung-32-curved',
          name: 'Samsung 32" Curved',
          brand: 'Samsung',
          category: 'Monitors',
          description: 'Immersive screen.',
          price: 399,
          imageUrl: 'assets/images/image16.png',
          rating: 4.6,
          reviewCount: 470,
          soldCount: 150),
      Product(
          id: 'acer-24-gaming',
          name: 'Acer 24" Gaming',
          brand: 'Acer',
          category: 'Monitors',
          description: 'Fast refresh monitor.',
          price: 229,
          imageUrl: 'assets/images/image17.png',
          rating: 4.5,
          reviewCount: 290,
          soldCount: 135),
      Product(
          id: 'hp-27-monitor',
          name: 'HP 27"',
          brand: 'HP',
          category: 'Monitors',
          description: 'Large sharp display.',
          price: 249,
          imageUrl: 'assets/images/image18.png',
          rating: 4.4,
          reviewCount: 230,
          soldCount: 100),
      Product(
          id: 'ugreen-65w-usbc',
          name: 'UGREEN 65W USB-C',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Fast charger.',
          price: 29,
          imageUrl: 'assets/images/image19.png',
          rating: 4.7,
          reviewCount: 880,
          soldCount: 400),
      Product(
          id: 'ugreen-45w-usbc',
          name: 'UGREEN 45W USB-C',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Portable charger.',
          price: 25,
          imageUrl: 'assets/images/image20.png',
          rating: 4.5,
          reviewCount: 650,
          soldCount: 300),
      Product(
          id: 'ugreen-60w-adapter',
          name: 'UGREEN 60W Adapter',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Multi-device adapter.',
          price: 27,
          imageUrl: 'assets/images/image21.png',
          rating: 4.6,
          reviewCount: 500,
          soldCount: 260),
      Product(
          id: 'ugreen-100w-gan',
          name: 'UGREEN 100W GaN',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Compact high-power charger.',
          price: 39,
          imageUrl: 'assets/images/image22.png',
          rating: 4.8,
          reviewCount: 920,
          soldCount: 420),
      Product(
          id: 'ugreen-30w-usbc',
          name: 'UGREEN 30W USB-C',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Smartphone charger.',
          price: 19,
          imageUrl: 'assets/images/image23.png',
          rating: 4.4,
          reviewCount: 480,
          soldCount: 210),
      Product(
          id: 'ugreen-65w-pd',
          name: 'UGREEN 65W PD',
          brand: 'UGREEN',
          category: 'UGREEN Chargers',
          description: 'Universal charger.',
          price: 32,
          imageUrl: 'assets/images/image24.png',
          rating: 4.6,
          reviewCount: 610,
          soldCount: 280),
      Product(
          id: 'steelseries-qck',
          name: 'SteelSeries QcK',
          brand: 'SteelSeries',
          category: 'Mouse Pads',
          description: 'Smooth surface mouse pad.',
          price: 19,
          imageUrl: 'assets/images/image25.png',
          rating: 4.6,
          reviewCount: 390,
          soldCount: 180),
      Product(
          id: 'razer-goliathus',
          name: 'Razer Goliathus',
          brand: 'Razer',
          category: 'Mouse Pads',
          description: 'Speed optimized mouse pad.',
          price: 24,
          imageUrl: 'assets/images/image26.png',
          rating: 4.5,
          reviewCount: 320,
          soldCount: 140),
      Product(
          id: 'corsair-mm300',
          name: 'Corsair MM300',
          brand: 'Corsair',
          category: 'Mouse Pads',
          description: 'Durable gaming mouse pad.',
          price: 29,
          imageUrl: 'assets/images/image27.png',
          rating: 4.7,
          reviewCount: 410,
          soldCount: 190),
      Product(
          id: 'logitech-g440',
          name: 'Logitech G440',
          brand: 'Logitech',
          category: 'Mouse Pads',
          description: 'Hard surface mouse pad.',
          price: 29,
          imageUrl: 'assets/images/image28.png',
          rating: 4.4,
          reviewCount: 250,
          soldCount: 110),
      Product(
          id: 'hyperx-fury-s',
          name: 'HyperX Fury S',
          brand: 'HyperX',
          category: 'Mouse Pads',
          description: 'Precision mouse pad.',
          price: 24,
          imageUrl: 'assets/images/image29.png',
          rating: 4.6,
          reviewCount: 360,
          soldCount: 160),
      Product(
          id: 'glorious-xxl',
          name: 'Glorious XXL',
          brand: 'Glorious',
          category: 'Mouse Pads',
          description: 'Large mouse pad.',
          price: 34,
          imageUrl: 'assets/images/image30.png',
          rating: 4.7,
          reviewCount: 500,
          soldCount: 220),
      Product(
          id: 'sony-wh-1000xm4',
          name: 'Sony WH-1000XM4',
          brand: 'Sony',
          category: 'Headphones',
          description: 'Noise-cancelling headphones.',
          price: 349,
          imageUrl: 'assets/images/image31.png',
          rating: 4.9,
          reviewCount: 1500,
          soldCount: 500),
      Product(
          id: 'bose-qc35-ii',
          name: 'Bose QC35 II',
          brand: 'Bose',
          category: 'Headphones',
          description: 'Comfortable and clear.',
          price: 299,
          imageUrl: 'assets/images/image32.png',
          rating: 4.8,
          reviewCount: 980,
          soldCount: 350),
      Product(
          id: 'sennheiser-hd450bt',
          name: 'Sennheiser HD450BT',
          brand: 'Sennheiser',
          category: 'Headphones',
          description: 'Deep bass headphones.',
          price: 199,
          imageUrl: 'assets/images/image33.png',
          rating: 4.5,
          reviewCount: 430,
          soldCount: 190),
      Product(
          id: 'jbl-live-650bt',
          name: 'JBL Live 650BT',
          brand: 'JBL',
          category: 'Headphones',
          description: 'Wireless over-ear headphones.',
          price: 149,
          imageUrl: 'assets/images/image34.png',
          rating: 4.4,
          reviewCount: 390,
          soldCount: 170),
      Product(
          id: 'airpods-max',
          name: 'AirPods Max',
          brand: 'Apple',
          category: 'Headphones',
          description: 'Premium sound headphones.',
          price: 549,
          imageUrl: 'assets/images/image35.png',
          rating: 4.8,
          reviewCount: 890,
          soldCount: 260),
      Product(
          id: 'beats-studio3',
          name: 'Beats Studio3',
          brand: 'Beats',
          category: 'Headphones',
          description: 'Stylish and powerful.',
          price: 299,
          imageUrl: 'assets/images/image36.png',
          rating: 4.6,
          reviewCount: 640,
          soldCount: 230),
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
