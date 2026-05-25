import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import '../state/wishlist_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final Product product;

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController _reviewController = TextEditingController();

  bool _isAddingToCart = false;
  bool _addedToCart = false;
  int selectedColorIndex = 0;
  int selectedRating = 5;

  final List<Map<String, dynamic>> colors = const [
    {'name': 'Blue', 'color': Color(0xFF1607B8)},
    {'name': 'Purple', 'color': Color(0xFF17085F)},
    {'name': 'Gray', 'color': Color(0xFF555555)},
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
      _addedToCart = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    context.read<CartProvider>().addProduct(widget.product);

    setState(() {
      _isAddingToCart = false;
      _addedToCart = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your review first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before reviewing.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reviewRef =
        _database.ref('products/${widget.product.id}/reviews').push();

    await reviewRef.set({
      'userId': user.uid,
      'userName': user.displayName ?? user.email ?? 'Customer',
      'rating': selectedRating,
      'comment': comment,
      'createdAt': ServerValue.timestamp,
    });

    _reviewController.clear();

    if (!mounted) return;

    setState(() {
      selectedRating = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review added successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> _parseReviews(dynamic value) {
    if (value == null || value is! Map) return [];

    final reviews = <Map<String, dynamic>>[];

    value.forEach((key, reviewValue) {
      if (reviewValue is Map) {
        final data = Map<String, dynamic>.from(reviewValue);
        data['id'] = key.toString();
        reviews.add(data);
      }
    });

    reviews.sort((a, b) {
      final aTime = (a['createdAt'] as num?)?.toInt() ?? 0;
      final bTime = (b['createdAt'] as num?)?.toInt() ?? 0;
      return bTime.compareTo(aTime);
    });

    return reviews;
  }

  double _averageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;

    double total = 0;
    for (final review in reviews) {
      total += (review['rating'] as num?)?.toDouble() ?? 0;
    }

    return total / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWishlisted =
        context.watch<WishlistProvider>().containsProduct(product.id);
    final selectedColorName = colors[selectedColorIndex]['name'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: _database.ref('products/${product.id}/reviews').onValue,
          builder: (context, snapshot) {
            final reviews = _parseReviews(snapshot.data?.snapshot.value);
            final averageRating = _averageRating(reviews);
            final reviewCount = reviews.length;

            final isTopProduct = averageRating >= 4.5 && reviewCount >= 3;

            return SingleChildScrollView(
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
                              .toggleProduct(product);
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
                      product.imageUrl,
                      height: 210,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.devices_rounded,
                          size: 120,
                          color: ProductDetailScreen.primaryBlue,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isTopProduct)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ProductDetailScreen.primaryBlue,
                        ),
                      ),
                      child: const Text(
                        'Top Product',
                        style: TextStyle(
                          color: ProductDetailScreen.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  if (isTopProduct) const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 21,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${averageRating.toStringAsFixed(1)} ($reviewCount reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Price: ${formatPrice(product.price)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ProductDetailScreen.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Color: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: selectedColorName),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(colors.length, (index) {
                      final color = colors[index]['color'] as Color;
                      final selected = selectedColorIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColorIndex = index;
                            });
                          },
                          child: _ColorCircle(
                            color: color,
                            selected: selected,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _isAddingToCart ? null : _addToCart,
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
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ProductDetailScreen.primaryBlue,
                              side: const BorderSide(
                                color: ProductDetailScreen.primaryBlue,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.contactSeller,
                              );
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
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProductDetailScreen.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _ReviewInput(
                    selectedRating: selectedRating,
                    controller: _reviewController,
                    onRatingChanged: (rating) {
                      setState(() {
                        selectedRating = rating;
                      });
                    },
                    onSubmit: _submitReview,
                  ),
                  const SizedBox(height: 24),
                  _ReviewList(reviews: reviews),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewInput extends StatelessWidget {
  const _ReviewInput({
    required this.selectedRating,
    required this.controller,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final int selectedRating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () => onRatingChanged(rating),
                child: Icon(
                  rating <= selectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ProductDetailScreen.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({
    required this.reviews,
  });

  final List<Map<String, dynamic>> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Text(
        'No reviews yet. Be the first to review this product.',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Reviews (${reviews.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ...reviews.map((review) {
          final userName = review['userName']?.toString() ?? 'Customer';
          final comment = review['comment']?.toString() ?? '';
          final rating = (review['rating'] as num?)?.toInt() ?? 5;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.3,
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

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    this.selected = false,
  });

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: selected ? 30 : 24,
      height: selected ? 30 : 24,
      padding: selected ? const EdgeInsets.all(3) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected
            ? Border.all(
                color: ProductDetailScreen.primaryBlue,
                width: 2,
              )
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
