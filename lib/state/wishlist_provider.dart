import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final List<WishlistItem> _items = [];
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DatabaseEvent>? _wishlistSubscription;

  List<WishlistItem> get items => List.unmodifiable(_items);

  WishlistProvider() {
    _authSubscription = _auth.authStateChanges().listen(_listenToWishlist);
  }

  void _listenToWishlist(User? user) {
    _wishlistSubscription?.cancel();
    _items.clear();

    if (user == null) {
      notifyListeners();
      return;
    }

    _wishlistSubscription =
        _database.ref('users/${user.uid}/wishlist').onValue.listen((event) {
      final value = event.snapshot.value;
      final nextItems = <WishlistItem>[];
      if (value is Map) {
        for (final entry in value.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          nextItems.add(
            WishlistItem(
              product: Product.fromJson(data, entry.key.toString()),
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

  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  Future<void> addProduct(Product product) async {
    if (!_items.any((item) => item.product.id == product.id)) {
      _items.add(WishlistItem(product: product));
      notifyListeners();
    }

    final user = _auth.currentUser;
    if (user == null) return;
    await _database.ref('users/${user.uid}/wishlist/${product.id}').update({
      ...product.toJson(),
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> removeProduct(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) return;
    await _database.ref('users/${user.uid}/wishlist/$productId').remove();
  }

  Future<void> toggleProduct(Product product) async {
    if (containsProduct(product.id)) {
      await removeProduct(product.id);
    } else {
      await addProduct(product);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
