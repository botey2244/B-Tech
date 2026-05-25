import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../models/product.dart';
import '../state/product_provider.dart';
import '../state/wishlist_provider.dart';

import 'contact_seller_screen.dart';
import 'notification_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color darkPurple = Color(0xFF281936);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  final List<String> categories = [
    'All',
    'Laptops',
    'Desktops',
    'Monitors',
    'UGREEN Chargers',
    'Mouse Pads',
    'Headphones',
    'RAM',
    'Game Controllers',
    'Laptop Backpacks',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void goToCategoryPage(String category) {
    Navigator.pushNamed(context, Routes.categories, arguments: category);
  }

  void goToContactSeller() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactSellerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final filteredProducts = productProvider.products.where((product) {
      final search = searchText.toLowerCase();
      return product.name.toLowerCase().contains(search) ||
          product.description.toLowerCase().contains(search) ||
          product.brand.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const _HomeDrawer(),
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const _Header(),
              const SizedBox(height: 22),
              _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => searchText = value),
                onClear: () {
                  setState(() {
                    searchText = '';
                    _searchController.clear();
                  });
                },
              ),
              const SizedBox(height: 22),
              _HeroBanner(onShopNowTap: goToContactSeller),
              const SizedBox(height: 28),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              _CategoryList(categories: categories, onTap: goToCategoryPage),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text(
                    'All Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredProducts.length} items',
                    style: const TextStyle(
                      color: HomeScreen.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (productProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: HomeScreen.primaryBlue,
                  ),
                )
              else if (filteredProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No products found'),
                  ),
                )
              else
                GridView.builder(
                  itemCount: filteredProducts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.55,
                  ),
                  itemBuilder: (context, index) {
                    return _ProductCard(product: filteredProducts[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatefulWidget {
  const _HomeDrawer();

  @override
  State<_HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<_HomeDrawer> {
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImage = prefs.getString('profile_image');

    if (savedImage != null && mounted) {
      setState(() {
        profileImageBytes = base64Decode(savedImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFECE6FF),
              backgroundImage: profileImageBytes != null
                  ? MemoryImage(profileImageBytes!)
                  : null,
              child: profileImageBytes == null
                  ? const Icon(
                      Icons.person,
                      size: 48,
                      color: HomeScreen.primaryBlue,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            const Text(
              'Jing Jing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'limpotkolbotey@gmail.com',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 28),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.grid_view_rounded,
              title: 'Categories',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  Routes.categories,
                  arguments: 'All',
                );
              },
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Cart',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.cart);
              },
            ),
            _DrawerItem(
              icon: Icons.favorite_border_rounded,
              title: 'Wishlist',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.wishlist);
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.profile);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HomeScreen.primaryBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu_rounded, size: 30),
            );
          },
        ),
        const Spacer(),
        Row(
          children: [
            Image.asset('assets/images/logo.png', width: 30, height: 30),
            const SizedBox(width: 0),
            const Text(
              'Tech',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
          child: const Icon(Icons.notifications, size: 28),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Search products...',
          border: InputBorder.none,
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(onTap: onClear, child: const Icon(Icons.close))
              : null,
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onShopNowTap});

  final VoidCallback onShopNowTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HomeScreen.darkPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Power Up\nYour World',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'best tech store',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShopNowTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        color: HomeScreen.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Image.asset(
              'assets/images/image.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.onTap,
  });

  final List<String> categories;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () => onTap(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isWishlisted =
        context.watch<WishlistProvider>().containsProduct(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFECECEC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF7F4FF),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.devices_rounded,
                            size: 42,
                            color: Color(0xFF1607B8),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<WishlistProvider>()
                              .toggleProduct(product);
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isWishlisted ? Colors.red : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _ProductRating(productId: product.id),
                      const Spacer(),
                      Text(
                        formatPrice(product.price),
                        style: const TextStyle(
                          color: Color(0xFF1607B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRating extends StatelessWidget {
  const _ProductRating({
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref('products/$productId/reviews').onValue,
      builder: (context, snapshot) {
        double totalRating = 0;
        int count = 0;

        final value = snapshot.data?.snapshot.value;

        if (value is Map) {
          for (final item in value.values) {
            if (item is Map) {
              totalRating += (item['rating'] as num?)?.toDouble() ?? 0;
              count++;
            }
          }
        }

        final average = count == 0 ? 0 : totalRating / count;

        return Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 15,
            ),
            const SizedBox(width: 3),
            Text(
              count == 0
                  ? 'No reviews'
                  : '${average.toStringAsFixed(1)} ($count)',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: HomeScreen.primaryBlue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        final routes = [
          Routes.home,
          Routes.categories,
          Routes.cart,
          Routes.wishlist,
          Routes.profile,
        ];

        if (index != 0) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
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
