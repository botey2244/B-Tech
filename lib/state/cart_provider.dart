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

  double get totalPrice {
    double total = 0;

    for (final item in _items) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

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

          final product = Product.fromJson(
            data,
            entry.key.toString(),
          );

          final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

          nextItems.add(
            CartItem(
              product: product,
              quantity: quantity,
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
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    int newQuantity = 1;

    if (index != -1) {
      newQuantity = _items[index].quantity + 1;
    }

    await _database.ref('users/${user.uid}/cart/${product.id}').update({
      ...product.toJson(),
      'quantity': newQuantity,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> removeOneProduct(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return;

    final item = _items[index];

    if (item.quantity <= 1) {
      await removeProduct(productId);
      return;
    }

    await _database.ref('users/${user.uid}/cart/$productId').update({
      'quantity': item.quantity - 1,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> removeProduct(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _database.ref('users/${user.uid}/cart/$productId').remove();
  }

  Future<void> clearCart() async {
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
