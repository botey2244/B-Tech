import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: wishlistProvider.items.isEmpty
            ? const Center(child: Text('Your wishlist is empty.'))
            : ListView.builder(
                itemCount: wishlistProvider.items.length,
                itemBuilder: (context, index) {
                  final item = wishlistProvider.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                  );
                },
              ),
      ),
    );
  }
}
