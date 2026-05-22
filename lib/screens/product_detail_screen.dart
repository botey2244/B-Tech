import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../state/cart_provider.dart';
import '../state/wishlist_provider.dart';

class ProductDetailData {
  const ProductDetailData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
  });

  final String imagePath;
  final String title;
  final String description;
  final String price;
  final String rating;
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAddingToCart = false;
  bool _addedToCart = false;

  Future<void> _addToCart(ProductDetailData product) async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
      _addedToCart = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    context.read<CartProvider>().addProduct(
          productFromDisplayData(
            title: product.title,
            description: product.description,
            price: product.price,
            imagePath: product.imagePath,
          ),
        );

    if (!mounted) return;
    setState(() {
      _isAddingToCart = false;
      _addedToCart = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Added to cart successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final product = arguments is ProductDetailData
        ? arguments
        : const ProductDetailData(
            imagePath: 'assets/images/image.png',
            title: 'Wireless Headphones',
            description:
                'Over-ear wireless headphones with deep bass and noise cancellation.',
            price: '\$149.99',
            rating: '4.6 (1,068 reviews)',
          );
    final wishlistProduct = productFromDisplayData(
      title: product.title,
      description: product.description,
      price: product.price,
      imagePath: product.imagePath,
    );
    final isWishlisted = context.watch<WishlistProvider>().containsProduct(
          wishlistProduct.id,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context
                          .read<WishlistProvider>()
                          .toggleProduct(wishlistProduct);
                    },
                    icon: Icon(
                      isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isWishlisted ? Colors.red : Colors.black,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  product.imagePath,
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    product.rating,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Price: ${product.price}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ProductDetailScreen.primaryBlue,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                product.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Color: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Black',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  _ColorCircle(
                    color: ProductDetailScreen.primaryBlue,
                    selected: true,
                  ),
                  SizedBox(width: 8),
                  _ColorCircle(color: Color(0xFF17085F)),
                  SizedBox(width: 8),
                  _ColorCircle(color: Color(0xFF555555)),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isAddingToCart
                            ? null
                            : () => _addToCart(product),
                        icon: _isAddingToCart
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                ),
                              )
                            : Icon(
                                _addedToCart
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.shopping_cart_outlined,
                                size: 21,
                              ),
                        label: Text(
                          _isAddingToCart
                              ? 'Adding...'
                              : _addedToCart
                                  ? 'Successful'
                                  : 'Add to Cart',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ProductDetailScreen.primaryBlue,
                          disabledForegroundColor:
                              ProductDetailScreen.primaryBlue,
                          side: const BorderSide(
                            color: ProductDetailScreen.primaryBlue,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.contactSeller);
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Contact Seller',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProductDetailScreen.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    this.selected = false,
  });

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      padding: selected ? const EdgeInsets.all(2) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: ProductDetailScreen.primaryBlue, width: 2)
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
