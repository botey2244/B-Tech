import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'receipt_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color softPurple = Color(0xFFF7F4FF);

  DatabaseReference? _ordersRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseDatabase.instance.ref('users/${user.uid}/orders');
  }

  @override
  Widget build(BuildContext context) {
    final ordersRef = _ordersRef();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: primaryBlue,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: softPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE7DEFF),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: primaryBlue,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'All your receipts and past orders are saved here.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _OrderHistoryList(ordersRef: ordersRef),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryList extends StatelessWidget {
  const _OrderHistoryList({
    required this.ordersRef,
  });

  final DatabaseReference? ordersRef;

  @override
  Widget build(BuildContext context) {
    if (ordersRef == null) {
      return const Center(child: Text('Please login to see orders.'));
    }

    return StreamBuilder<DatabaseEvent>(
      stream: ordersRef!.orderByChild('createdAt').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: OrderHistoryScreen.primaryBlue,
            ),
          );
        }

        final value = snapshot.data?.snapshot.value;

        if (value == null || value is! Map) {
          return const Center(
            child: Text(
              'No orders yet.',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final orders = <Map<String, dynamic>>[];

        value.forEach((key, orderValue) {
          if (orderValue is Map) {
            final data = Map<String, dynamic>.from(orderValue);
            data['id'] = key.toString();
            orders.add(data);
          }
        });

        orders.sort((a, b) {
          final aTime = (a['createdAt'] as num?)?.toInt() ?? 0;
          final bTime = (b['createdAt'] as num?)?.toInt() ?? 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _OrderHistoryCard(order: orders[index]);
          },
        );
      },
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({
    required this.order,
  });

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? '';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final createdAt = order['createdAt'];
    final items = _parseItems(order['items']);

    final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};
    final imageUrl =
        firstItem['imageUrl']?.toString() ?? 'assets/images/image.png';
    final name = firstItem['name']?.toString() ?? 'Order';

    final quantity = items.fold<int>(0, (sum, item) {
      final q = item['quantity'];
      if (q is num) return sum + q.toInt();
      return sum;
    });

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(orderId: orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 66,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.shopping_bag_outlined,
                    color: OrderHistoryScreen.primaryBlue,
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$quantity item${quantity > 1 ? 's' : ''} • ${_formatDate(createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: OrderHistoryScreen.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: OrderHistoryScreen.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Map<String, dynamic>> _parseItems(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .where((item) => item is Map)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    if (value is Map) {
      return value.values
          .where((item) => item is Map)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    return [];
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! num) return 'No date';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return '${date.month}/${date.day}/${date.year}';
  }
}
