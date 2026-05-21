import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/app_button.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleProduct = Product(
      id: 'sample',
      name: 'Minimal Product',
      description: 'A clean product layout with Firebase-driven details.',
      price: 34.99,
      imageUrl: '',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('Product image placeholder')),
              ),
            ),
            const SizedBox(height: 16),
            Text(sampleProduct.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(sampleProduct.description),
            const SizedBox(height: 16),
            Text('\$${sampleProduct.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            AppButton(label: 'Add to Cart', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
