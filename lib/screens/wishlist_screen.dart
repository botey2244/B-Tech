import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';
import '../state/wishlist_provider.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Set<String> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final items = wishlist.items;

    final bool allSelected =
        items.isNotEmpty && selectedIds.length == items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'My Wishlist',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFECE6FF),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: WishlistScreen.primaryBlue,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} ${items.length == 1 ? 'Item' : 'Items'}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Items you love, saved for later',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (allSelected) {
                          selectedIds.clear();
                        } else {
                          selectedIds
                            ..clear()
                            ..addAll(items.map((item) => item.product.id));
                        }
                      });
                    },
                    child: Icon(
                      allSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: allSelected
                          ? WishlistScreen.primaryBlue
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select All',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: selectedIds.isEmpty
                        ? null
                        : () async {
                            final wishlistProvider =
                                context.read<WishlistProvider>();

                            for (final id in selectedIds.toList()) {
                              await wishlistProvider.removeProduct(id);
                            }

                            setState(() {
                              selectedIds.clear();
                            });
                          },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedIds.isEmpty
                            ? Colors.red.withValues(alpha: 0.35)
                            : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (items.isEmpty)
                const _EmptyWishlist()
              else
                ...items.map(
                  (item) => _WishlistItem(
                    product: item.product,
                    isSelected: selectedIds.contains(item.product.id),
                    onSelect: () {
                      setState(() {
                        if (selectedIds.contains(item.product.id)) {
                          selectedIds.remove(item.product.id);
                        } else {
                          selectedIds.add(item.product.id);
                        }
                      });
                    },
                  ),
                ),
              const SizedBox(height: 28),
              const _InfoBox(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishlistItem extends StatelessWidget {
  const _WishlistItem({
    required this.product,
    required this.isSelected,
    required this.onSelect,
  });

  final Product product;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onSelect,
              child: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: isSelected ? WishlistScreen.primaryBlue : Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              product.imageUrl,
              width: 66,
              height: 58,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: ${formatPrice(product.price)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: WishlistScreen.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.read<WishlistProvider>().removeProduct(product.id);
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 92,
                  height: 28,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<CartProvider>().addProduct(product);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart successfully.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 12),
                    label: const Text('Add to Cart'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WishlistScreen.primaryBlue,
                      side: const BorderSide(
                        color: WishlistScreen.primaryBlue,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: WishlistScreen.primaryBlue,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No wishlist items yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Tap a heart on any product to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: WishlistScreen.primaryBlue,
            size: 32,
          ),
          SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Don\'t see something you love?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Keep exploring and add more items to your wishlist.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: WishlistScreen.primaryBlue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 3) return;

        final routes = [
          Routes.home,
          Routes.categories,
          Routes.cart,
          Routes.wishlist,
          Routes.profile,
        ];

        Navigator.pushReplacementNamed(context, routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
