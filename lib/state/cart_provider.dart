import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final List<CartItem> _items = [];
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DatabaseEvent>? _cartSubscription;

  List<CartItem> get items => List.unmodifiable(_items);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.total);

  CartProvider() {
    _authSubscription = _auth.authStateChanges().listen(_listenToCart);
  }

  void _listenToCart(User? user) {
    _cartSubscription?.cancel();
    _items.clear();

    if (user == null) {
      notifyListeners();
      return;
    }

    _cartSubscription =
        _database.ref('users/${user.uid}/cart').onValue.listen((event) {
      final value = event.snapshot.value;
      final nextItems = <CartItem>[];
      if (value is Map) {
        for (final entry in value.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          nextItems.add(
            CartItem(
              product: Product.fromJson(data, entry.key.toString()),
              quantity: (data['quantity'] as num?)?.toInt() ?? 1,
            ),
          );
        }
      }
      _items
        ..clear()
        ..addAll(nextItems);
      notifyListeners();
    });
  }

  Future<void> addProduct(Product product) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    final quantity = index >= 0 ? _items[index].quantity + 1 : 1;
    if (index >= 0) {
      _items[index].quantity = quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;

    await _database.ref('users/${user.uid}/cart/${product.id}').update({
      ...product.toJson(),
      'quantity': quantity,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> removeProduct(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;
    await _database.ref('users/${user.uid}/cart/$productId').remove();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;
    await _database.ref('users/${user.uid}/cart').remove();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cartSubscription?.cancel();
    super.dispose();
  }
}
