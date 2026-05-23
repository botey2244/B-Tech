import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'MacBook Pro',
      description: 'Powerful laptop for work and study',
      price: 1299,
      imageUrl: 'assets/images/image.png',
    ),
    Product(
      id: '2',
      name: 'Dell Desktop',
      description: 'Desktop computer for office and gaming',
      price: 899,
      imageUrl: 'assets/images/image.png',
    ),
    Product(
      id: '3',
      name: 'Wireless Headphones',
      description: 'Noise cancelling headphones',
      price: 199,
      imageUrl: 'assets/images/image.png',
    ),
    Product(
      id: '4',
      name: 'Gaming Monitor',
      description: 'High quality display monitor',
      price: 299,
      imageUrl: 'assets/images/image.png',
    ),
  ];

  bool get isLoading => false;

  List<Product> get products => List.unmodifiable(_products);
}
