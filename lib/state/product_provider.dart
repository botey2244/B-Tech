import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_database_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseDatabaseService _service = FirebaseDatabaseService();
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      products = await _service.fetchProducts();
    } catch (_) {
      errorMessage = 'Could not load products from Firebase.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
