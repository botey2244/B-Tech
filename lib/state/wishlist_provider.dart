import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<WishlistItem> _items = [];

  List<WishlistItem> get items => List.unmodifiable(_items);

  void addProduct(Product product) {
    if (!_items.any((item) => item.product.id == product.id)) {
      _items.add(WishlistItem(product: product));
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
}
