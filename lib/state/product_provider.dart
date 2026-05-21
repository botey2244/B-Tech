import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Product> products = [];
  bool isLoading = false;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();
    products = await _service.fetchProducts();
    isLoading = false;
    notifyListeners();
  }
}
