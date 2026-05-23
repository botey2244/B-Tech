import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice {
    double total = 0;
    for (final item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void addProduct(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index == -1) {
      _items.add(CartItem(product: product, quantity: 1));
    } else {
      final oldItem = _items[index];
      _items[index] = CartItem(
        product: oldItem.product,
        quantity: oldItem.quantity + 1,
      );
    }

    notifyListeners();
  }

  void removeOneProduct(String productId) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return;

    final oldItem = _items[index];

    if (oldItem.quantity > 1) {
      _items[index] = CartItem(
        product: oldItem.product,
        quantity: oldItem.quantity - 1,
      );
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
