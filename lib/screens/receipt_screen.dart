import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/product_helpers.dart';
import '../state/cart_provider.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color softPurple = Color(0xFFF7F4FF);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    const shipping = 2.0;
    final subtotal = cart.totalPrice;
    final total = subtotal == 0 ? 0.0 : subtotal + shipping;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _ReceiptAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFE7DEFF),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: primaryBlue,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Receipt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Thank you! This is your receipt.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'May 18, 2026 at 10:30 AM',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Divider(),
                    const SizedBox(height: 28),
                    _ReceiptItems(items: items),
                    const SizedBox(height: 26),
                    _TotalBox(
                      subtotal: subtotal,
                      shipping: subtotal == 0 ? 0 : shipping,
                      total: total,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptAppBar extends StatelessWidget {
  const _ReceiptAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: ReceiptScreen.primaryBlue,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _ReceiptItems extends StatelessWidget {
  const _ReceiptItems({required this.items});

  final List items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No items in receipt',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('Product', style: _headerStyle),
              ),
              Expanded(
                flex: 2,
                child: Text('Qty', style: _headerStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Total',
                  textAlign: TextAlign.end,
                  style: _headerStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) {
          final product = item.product;
          final quantity = item.quantity;
          final itemTotal = product.price * quantity;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _rowStyle,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'x$quantity',
                    style: _rowStyle,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatPrice(itemTotal),
                    textAlign: TextAlign.end,
                    style: _rowStyle,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: formatPrice(subtotal)),
          const SizedBox(height: 16),
          _TotalRow(label: 'Shipping', value: formatPrice(shipping)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
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
            fontSize: bold ? 19 : 16,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 19 : 16,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w800,
);

const TextStyle _rowStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
);
