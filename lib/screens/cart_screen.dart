import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../widgets/app_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppButton(label: 'Checkout', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
