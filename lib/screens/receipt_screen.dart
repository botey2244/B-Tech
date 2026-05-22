import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 26),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFE7DEFF),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Receipt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Thank you! This is your receipt.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'May 18, 2026 at 10:30 AM',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 28),
                    const _ReceiptTable(),
                    const SizedBox(height: 28),
                    const _TotalBox(),
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

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: ReceiptScreen.primaryBlue,
              size: 27,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 18,
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

class _ReceiptTable extends StatelessWidget {
  const _ReceiptTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TableHeader(),
        _TableRowItem(product: 'Macbook M1', amount: '1', price: '\$1,099'),
        _TableRowItem(product: 'Macbook M1', amount: '1', price: '\$1,099'),
        _TableRowItem(product: 'Macbook M1', amount: '1', price: '\$1,099'),
        _TableRowItem(product: 'Macbook M1', amount: '1', price: '\$1,099'),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text('Product', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('Amount', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('Price', style: _headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text('Total', style: _headerStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({
    required this.product,
    required this.amount,
    required this.price,
  });

  final String product;
  final String amount;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(product, style: _rowStyle)),
          Expanded(flex: 2, child: Text(amount, style: _rowStyle)),
          Expanded(flex: 2, child: Text(price, style: _rowStyle)),
          Expanded(
            flex: 2,
            child: Text(price, style: _rowStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _TotalRow(label: 'Subtotal', value: '\$4,800.95'),
          SizedBox(height: 12),
          _TotalRow(label: 'Shipping', value: '\$2.00'),
          SizedBox(height: 12),
          _TotalRow(label: 'Total', value: '\$4,802.95'),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: _totalStyle),
        const Spacer(),
        Text(value, style: _totalStyle),
      ],
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w800,
);

const TextStyle _rowStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
);

const TextStyle _totalStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w800,
);
