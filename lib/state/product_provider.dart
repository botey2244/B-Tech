import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final List<Product> _products = [];

  StreamSubscription<DatabaseEvent>? _productsSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => List.unmodifiable(_products);

  ProductProvider() {
    _seedProductsIfEmpty();
    _listenToProducts();
  }

  Future<void> _seedProductsIfEmpty() async {
    final snapshot = await _database.ref('products').get();

    if (snapshot.exists) return;

    await seedProducts();
  }

  void _listenToProducts() {
    _productsSubscription = _database.ref('products').onValue.listen(
      (event) {
        final value = event.snapshot.value;
        final nextProducts = <Product>[];

        if (value is Map) {
          for (final entry in value.entries) {
            final data = Map<String, dynamic>.from(entry.value as Map);

            nextProducts.add(
              Product.fromJson(
                data,
                entry.key.toString(),
              ),
            );
          }
        }

        _products
          ..clear()
          ..addAll(nextProducts);

        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'Could not load products.';
        notifyListeners();
      },
    );
  }

  Future<void> seedProducts() async {
    final ref = _database.ref('products');

    final products = [
      // Old products
      Product(
        id: 'macbook_pro_14',
        name: 'MacBook Pro 14-inch',
        brand: 'Apple',
        description:
            'Apple laptop with powerful performance for study, design, coding, and professional work.',
        price: 1299,
        imageUrl: 'assets/images/macbook.png',
        category: 'Laptops',
      ),
      Product(
        id: 'dell_inspiron_desktop',
        name: 'Dell Inspiron Desktop',
        brand: 'Dell',
        description:
            'Reliable desktop computer for office work, study, and daily productivity.',
        price: 899,
        imageUrl: 'assets/images/dell_desktop.png',
        category: 'Desktops',
      ),
      Product(
        id: 'sony_wireless_headphones',
        name: 'Sony Wireless Headphones',
        brand: 'Sony',
        description:
            'Comfortable wireless headphones with clear sound and noise cancellation.',
        price: 149.99,
        imageUrl: 'assets/images/headphones.png',
        category: 'Headphones',
      ),
      Product(
        id: 'lenovo_ideapad_slim_3',
        name: 'Lenovo IdeaPad Slim 3',
        brand: 'Lenovo',
        description:
            'Lightweight laptop for students, online classes, documents, and everyday tasks.',
        price: 499.99,
        imageUrl: 'assets/images/lenovo.png',
        category: 'Laptops',
      ),
      Product(
        id: 'lg_ultragear_monitor',
        name: 'LG UltraGear Monitor',
        brand: 'LG',
        description:
            'High-quality monitor for gaming, design, entertainment, and multitasking.',
        price: 299,
        imageUrl: 'assets/images/monitor.png',
        category: 'Monitors',
      ),

      // More laptops
      Product(
        id: 'dell_xps_13',
        name: 'Dell XPS 13',
        brand: 'Dell',
        description: 'Compact ultrabook.',
        price: 1099,
        imageUrl: 'assets/images/image1.png',
        category: 'Laptops',
      ),
      Product(
        id: 'hp_pavilion_laptop',
        name: 'HP Pavilion',
        brand: 'HP',
        description: 'Reliable daily laptop.',
        price: 699,
        imageUrl: 'assets/images/image2.png',
        category: 'Laptops',
      ),
      Product(
        id: 'asus_zenbook',
        name: 'Asus ZenBook',
        brand: 'Asus',
        description: 'Thin and fast laptop.',
        price: 899,
        imageUrl: 'assets/images/image3.png',
        category: 'Laptops',
      ),
      Product(
        id: 'acer_swift_3',
        name: 'Acer Swift 3',
        brand: 'Acer',
        description: 'Budget-friendly laptop.',
        price: 549,
        imageUrl: 'assets/images/image4.png',
        category: 'Laptops',
      ),

      // Desktops
      Product(
        id: 'hp_pavilion_desktop',
        name: 'HP Pavilion Desktop',
        brand: 'HP',
        description: 'Reliable desktop.',
        price: 799,
        imageUrl: 'assets/images/image5.png',
        category: 'Desktops',
      ),
      Product(
        id: 'lenovo_ideacentre',
        name: 'Lenovo IdeaCentre',
        brand: 'Lenovo',
        description: 'Compact all-in-one.',
        price: 999,
        imageUrl: 'assets/images/image6.png',
        category: 'Desktops',
      ),
      Product(
        id: 'apple_imac',
        name: 'Apple iMac',
        brand: 'Apple',
        description: 'Premium desktop.',
        price: 1299,
        imageUrl: 'assets/images/image7.png',
        category: 'Desktops',
      ),
      Product(
        id: 'dell_optiplex',
        name: 'Dell OptiPlex',
        brand: 'Dell',
        description: 'Business desktop.',
        price: 1199,
        imageUrl: 'assets/images/image8.png',
        category: 'Desktops',
      ),
      Product(
        id: 'hp_aio_22',
        name: 'HP AIO 22-inch',
        brand: 'HP',
        description: 'Affordable all-in-one.',
        price: 699,
        imageUrl: 'assets/images/image9.png',
        category: 'Desktops',
      ),

      // Monitors
      Product(
        id: 'dell_ultrasharp_27',
        name: 'Dell UltraSharp 27-inch',
        brand: 'Dell',
        description: 'High-res monitor.',
        price: 399,
        imageUrl: 'assets/images/image10.png',
        category: 'Monitors',
      ),
      Product(
        id: 'lg_24_monitor',
        name: 'LG 24-inch',
        brand: 'LG',
        description: 'Full HD display.',
        price: 149,
        imageUrl: 'assets/images/image11.png',
        category: 'Monitors',
      ),
      Product(
        id: 'asus_proart_27',
        name: 'Asus ProArt 27-inch',
        brand: 'Asus',
        description: 'Color-accurate monitor.',
        price: 499,
        imageUrl: 'assets/images/image12.png',
        category: 'Monitors',
      ),
      Product(
        id: 'samsung_32_curved',
        name: 'Samsung 32-inch Curved',
        brand: 'Samsung',
        description: 'Immersive screen.',
        price: 399,
        imageUrl: 'assets/images/image13.png',
        category: 'Monitors',
      ),
      Product(
        id: 'acer_24_gaming',
        name: 'Acer 24-inch Gaming',
        brand: 'Acer',
        description: 'Fast refresh monitor.',
        price: 229,
        imageUrl: 'assets/images/image14.png',
        category: 'Monitors',
      ),
      Product(
        id: 'hp_27_monitor',
        name: 'HP 27-inch',
        brand: 'HP',
        description: 'Large sharp display.',
        price: 249,
        imageUrl: 'assets/images/image15.png',
        category: 'Monitors',
      ),

      // UGREEN Chargers
      Product(
        id: 'ugreen_65w_usb_c',
        name: 'UGREEN 65W USB-C',
        brand: 'UGREEN',
        description: 'Fast charger.',
        price: 29,
        imageUrl: 'assets/images/image16.png',
        category: 'UGREEN Chargers',
      ),
      Product(
        id: 'ugreen_45w_usb_c',
        name: 'UGREEN 45W USB-C',
        brand: 'UGREEN',
        description: 'Portable charger.',
        price: 25,
        imageUrl: 'assets/images/image17.png',
        category: 'UGREEN Chargers',
      ),
      Product(
        id: 'ugreen_60w_adapter',
        name: 'UGREEN 60W Adapter',
        brand: 'UGREEN',
        description: 'Multi-device adapter.',
        price: 27,
        imageUrl: 'assets/images/image18.png',
        category: 'UGREEN Chargers',
      ),
      Product(
        id: 'ugreen_100w_gan',
        name: 'UGREEN 100W GaN',
        brand: 'UGREEN',
        description: 'Compact high-power charger.',
        price: 39,
        imageUrl: 'assets/images/image19.png',
        category: 'UGREEN Chargers',
      ),
      Product(
        id: 'ugreen_30w_usb_c',
        name: 'UGREEN 30W USB-C',
        brand: 'UGREEN',
        description: 'Smartphone charger.',
        price: 19,
        imageUrl: 'assets/images/image20.png',
        category: 'UGREEN Chargers',
      ),
      Product(
        id: 'ugreen_65w_pd',
        name: 'UGREEN 65W PD',
        brand: 'UGREEN',
        description: 'Universal charger.',
        price: 32,
        imageUrl: 'assets/images/image21.png',
        category: 'UGREEN Chargers',
      ),

      // Mouse Pads
      Product(
        id: 'steelseries_qck',
        name: 'SteelSeries QcK',
        brand: 'SteelSeries',
        description: 'Smooth surface.',
        price: 19,
        imageUrl: 'assets/images/image22.png',
        category: 'Mouse Pads',
      ),
      Product(
        id: 'razer_goliathus',
        name: 'Razer Goliathus',
        brand: 'Razer',
        description: 'Speed optimized mouse pad.',
        price: 24,
        imageUrl: 'assets/images/image23.png',
        category: 'Mouse Pads',
      ),
      Product(
        id: 'corsair_mm300',
        name: 'Corsair MM300',
        brand: 'Corsair',
        description: 'Durable gaming mouse pad.',
        price: 29,
        imageUrl: 'assets/images/image24.png',
        category: 'Mouse Pads',
      ),
      Product(
        id: 'logitech_g440',
        name: 'Logitech G440',
        brand: 'Logitech',
        description: 'Hard surface mouse pad.',
        price: 29,
        imageUrl: 'assets/images/image25.png',
        category: 'Mouse Pads',
      ),
      Product(
        id: 'hyperx_fury_s',
        name: 'HyperX Fury S',
        brand: 'HyperX',
        description: 'Precision mouse pad.',
        price: 24,
        imageUrl: 'assets/images/image26.png',
        category: 'Mouse Pads',
      ),
      Product(
        id: 'glorious_xxl',
        name: 'Glorious XXL',
        brand: 'Glorious',
        description: 'Large mouse pad.',
        price: 34,
        imageUrl: 'assets/images/image27.png',
        category: 'Mouse Pads',
      ),

      // Headphones
      Product(
        id: 'sony_wh_1000xm4',
        name: 'Sony WH-1000XM4',
        brand: 'Sony',
        description: 'Noise-cancelling headphones.',
        price: 349,
        imageUrl: 'assets/images/image28.png',
        category: 'Headphones',
      ),
      Product(
        id: 'bose_qc35_ii',
        name: 'Bose QC35 II',
        brand: 'Bose',
        description: 'Comfortable and clear.',
        price: 299,
        imageUrl: 'assets/images/image29.png',
        category: 'Headphones',
      ),
      Product(
        id: 'sennheiser_hd450bt',
        name: 'Sennheiser HD450BT',
        brand: 'Sennheiser',
        description: 'Deep bass headphones.',
        price: 199,
        imageUrl: 'assets/images/image30.png',
        category: 'Headphones',
      ),
      Product(
        id: 'jbl_live_650bt',
        name: 'JBL Live 650BT',
        brand: 'JBL',
        description: 'Wireless over-ear headphones.',
        price: 149,
        imageUrl: 'assets/images/image31.png',
        category: 'Headphones',
      ),
      Product(
        id: 'airpods_max',
        name: 'AirPods Max',
        brand: 'Apple',
        description: 'Premium sound headphones.',
        price: 549,
        imageUrl: 'assets/images/image32.png',
        category: 'Headphones',
      ),
      Product(
        id: 'beats_studio3',
        name: 'Beats Studio3',
        brand: 'Beats',
        description: 'Stylish and powerful.',
        price: 299,
        imageUrl: 'assets/images/image33.png',
        category: 'Headphones',
      ),

      // RAM
      Product(
        id: 'corsair_16gb_ddr4',
        name: 'Corsair 16GB DDR4',
        brand: 'Corsair',
        description: 'Fast memory.',
        price: 89,
        imageUrl: 'assets/images/image34.png',
        category: 'RAM',
      ),
      Product(
        id: 'gskill_16gb_ddr4',
        name: 'G.SKILL 16GB DDR4',
        brand: 'G.SKILL',
        description: 'Reliable memory.',
        price: 79,
        imageUrl: 'assets/images/image35.png',
        category: 'RAM',
      ),
      Product(
        id: 'kingston_16gb_ddr4',
        name: 'Kingston 16GB DDR4',
        brand: 'Kingston',
        description: 'Stable memory.',
        price: 85,
        imageUrl: 'assets/images/image36.png',
        category: 'RAM',
      ),
      Product(
        id: 'crucial_16gb_ddr4',
        name: 'Crucial 16GB DDR4',
        brand: 'Crucial',
        description: 'Low-latency memory.',
        price: 82,
        imageUrl: 'assets/images/image37.png',
        category: 'RAM',
      ),
      Product(
        id: 'patriot_16gb_ddr4',
        name: 'Patriot 16GB DDR4',
        brand: 'Patriot',
        description: 'Gaming optimized memory.',
        price: 88,
        imageUrl: 'assets/images/image38.png',
        category: 'RAM',
      ),
      Product(
        id: 'team_tforce_16gb_ddr4',
        name: 'Team T-Force 16GB DDR4',
        brand: 'Team T-Force',
        description: 'RGB-lit memory.',
        price: 95,
        imageUrl: 'assets/images/image39.png',
        category: 'RAM',
      ),

      // Game Controllers
      Product(
        id: 'xbox_wireless_controller',
        name: 'Xbox Wireless Controller',
        brand: 'Xbox',
        description: 'PC and Xbox controller.',
        price: 59,
        imageUrl: 'assets/images/image40.png',
        category: 'Game Controllers',
      ),
      Product(
        id: 'dualshock_4',
        name: 'DualShock 4',
        brand: 'PlayStation',
        description: 'PlayStation controller.',
        price: 49,
        imageUrl: 'assets/images/image41.png',
        category: 'Game Controllers',
      ),
      Product(
        id: 'switch_pro_controller',
        name: 'Switch Pro Controller',
        brand: 'Nintendo',
        description: 'Nintendo controller.',
        price: 69,
        imageUrl: 'assets/images/image42.png',
        category: 'Game Controllers',
      ),
      Product(
        id: 'logitech_f310',
        name: 'Logitech F310',
        brand: 'Logitech',
        description: 'PC wired controller.',
        price: 29,
        imageUrl: 'assets/images/image43.png',
        category: 'Game Controllers',
      ),
      Product(
        id: 'razer_wolverine',
        name: 'Razer Wolverine',
        brand: 'Razer',
        description: 'Gaming pro controller.',
        price: 159,
        imageUrl: 'assets/images/image44.png',
        category: 'Game Controllers',
      ),
      Product(
        id: '8bitdo_pro_2',
        name: '8Bitdo Pro 2',
        brand: '8Bitdo',
        description: 'Retro style controller.',
        price: 49,
        imageUrl: 'assets/images/image45.png',
        category: 'Game Controllers',
      ),

      // Laptop Backpacks
      Product(
        id: 'targus_15_6_backpack',
        name: 'Targus 15.6-inch',
        brand: 'Targus',
        description: 'Sleek and light backpack.',
        price: 59,
        imageUrl: 'assets/images/image46.png',
        category: 'Laptop Backpacks',
      ),
      Product(
        id: 'swissgear_17_backpack',
        name: 'SwissGear 17-inch',
        brand: 'SwissGear',
        description: 'Durable backpack.',
        price: 79,
        imageUrl: 'assets/images/image47.png',
        category: 'Laptop Backpacks',
      ),
      Product(
        id: 'herschel_pop_quiz',
        name: 'Herschel Pop Quiz',
        brand: 'Herschel',
        description: 'Stylish backpack.',
        price: 69,
        imageUrl: 'assets/images/image48.png',
        category: 'Laptop Backpacks',
      ),
      Product(
        id: 'samsonite_tectonic',
        name: 'Samsonite Tectonic',
        brand: 'Samsonite',
        description: 'Business style backpack.',
        price: 89,
        imageUrl: 'assets/images/image49.png',
        category: 'Laptop Backpacks',
      ),
      Product(
        id: 'amazonbasics_backpack',
        name: 'AmazonBasics Backpack',
        brand: 'AmazonBasics',
        description: 'Everyday use backpack.',
        price: 39,
        imageUrl: 'assets/images/image50.png',
        category: 'Laptop Backpacks',
      ),
      Product(
        id: 'thule_subterra',
        name: 'Thule Subterra',
        brand: 'Thule',
        description: 'Protective backpack.',
        price: 99,
        imageUrl: 'assets/images/image51.png',
        category: 'Laptop Backpacks',
      ),
    ];

    final updates = <String, Object?>{};

    for (final product in products) {
      updates[product.id] = product.toJson();
    }

    await ref.set(updates);
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
