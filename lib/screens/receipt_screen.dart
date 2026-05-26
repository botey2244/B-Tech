import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../core/product_helpers.dart';
import '../services/receipt_saver_service.dart';

class ReceiptScreen extends StatelessWidget {
  ReceiptScreen({
    super.key,
    this.orderId,
  });

  final String? orderId;
  final ScreenshotController screenshotController = ScreenshotController();

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color softPurple = Color(0xFFF7F4FF);

  DatabaseReference? _orderRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || orderId == null) return null;

    return FirebaseDatabase.instance.ref(
      'users/${user.uid}/orders/$orderId',
    );
  }

  Future<void> _saveReceipt(
    BuildContext context, {
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double total,
  }) async {
    // Show a loading indicator while saving.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14),
              Text('Saving receipt to Photos…'),
            ],
          ),
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );

    final success = await ReceiptSaverService.captureAndSave(
      controller: screenshotController,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Receipt saved to your Photos!'
                : '❌ Could not save receipt. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ref = _orderRef();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ref == null
            ? Column(
                children: [
                  _ReceiptAppBar(onDownload: () {}),
                  const Expanded(
                    child: Center(child: Text('Order not found')),
                  ),
                ],
              )
            : StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        _ReceiptAppBar(onDownload: () {}),
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final value = snapshot.data?.snapshot.value;

                  if (value == null || value is! Map) {
                    return Column(
                      children: [
                        _ReceiptAppBar(onDownload: () {}),
                        const Expanded(
                          child: Center(child: Text('Order not found')),
                        ),
                      ],
                    );
                  }

                  final order = Map<String, dynamic>.from(value);
                  final items = _parseItems(order['items']);

                  final subtotal =
                      (order['subtotal'] as num?)?.toDouble() ?? 0.0;
                  final shipping =
                      (order['shipping'] as num?)?.toDouble() ?? 0.0;
                  final total = (order['total'] as num?)?.toDouble() ?? 0.0;

                  return Column(
                    children: [
                      _ReceiptAppBar(
                        onDownload: () => _saveReceipt(
                          context,
                          order: order,
                          items: items,
                          subtotal: subtotal,
                          shipping: shipping,
                          total: total,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
                          child: Screenshot(
                            controller: screenshotController,
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _ReceiptHeader(order: order),
                                  const SizedBox(height: 22),
                                  _OrderInfoBox(orderId: orderId),
                                  const SizedBox(height: 22),
                                  _ReceiptItems(items: items),
                                  const SizedBox(height: 22),
                                  _TotalBox(
                                    subtotal: subtotal,
                                    shipping: shipping,
                                    total: total,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  static List<Map<String, dynamic>> _parseItems(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static String formatReceiptDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! num) return 'No date';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.month}/${date.day}/${date.year} at $hour:$minute $amPm';
  }
}

class _ReceiptAppBar extends StatelessWidget {
  const _ReceiptAppBar({
    required this.onDownload,
  });

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: ReceiptScreen.primaryBlue,
              size: 28,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDownload,
            child: const Icon(
              Icons.file_download_outlined,
              color: ReceiptScreen.primaryBlue,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptHeader extends StatelessWidget {
  const _ReceiptHeader({
    required this.order,
  });

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ReceiptScreen.softPurple,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE7DEFF),
            child: Icon(
              Icons.check_circle_rounded,
              color: ReceiptScreen.primaryBlue,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Receipt Created',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your order receipt has been saved successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ReceiptScreen.formatReceiptDate(order['createdAt']),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderInfoBox extends StatelessWidget {
  const _OrderInfoBox({
    required this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF7F4FF),
            child: Icon(
              Icons.receipt_long_outlined,
              color: ReceiptScreen.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderId ?? 'Not saved',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptItems extends StatelessWidget {
  const _ReceiptItems({
    required this.items,
  });

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No items in receipt',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            final name = item['name']?.toString() ?? 'Product';
            final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
            final total = (item['total'] as num?)?.toDouble() ?? 0.0;
            final imageUrl =
                item['imageUrl']?.toString() ?? 'assets/images/image.png';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 50,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F4FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.shopping_bag_outlined,
                          color: ReceiptScreen.primaryBlue,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Qty: $quantity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  final double subtotal;
  final double shipping;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ReceiptScreen.softPurple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: formatPrice(subtotal)),
          const SizedBox(height: 15),
          _TotalRow(label: 'Shipping', value: formatPrice(shipping)),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFFD8D1F2)),
          const SizedBox(height: 15),
          _TotalRow(
            label: 'Total',
            value: formatPrice(total),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 20 : 15,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 20 : 15,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            color: bold ? ReceiptScreen.primaryBlue : Colors.black,
          ),
        ),
      ],
    );
  }
}
