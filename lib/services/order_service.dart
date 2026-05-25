import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/cart_item.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<String?> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double total,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userRef = _database.ref('users/${user.uid}');
    final orderRef = userRef.child('orders').push();

    await orderRef.set({
      'items': items.map((item) {
        return {
          'id': item.product.id,
          'name': item.product.name,
          'description': item.product.description,
          'price': item.product.price,
          'imageUrl': item.product.imageUrl,
          'quantity': item.quantity,
          'total': item.product.price * item.quantity,
        };
      }).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'createdAt': ServerValue.timestamp,
    });

    final totalItems = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final notificationRef = userRef.child('notifications').push();

    await notificationRef.set({
      'title': 'Receipt Generated',
      'message':
          'Your receipt for $totalItems item${totalItems > 1 ? 's' : ''} is ready.',
      'isUnread': true,
      'orderId': orderRef.key,
      'createdAt': ServerValue.timestamp,
    });

    return orderRef.key;
  }
}
