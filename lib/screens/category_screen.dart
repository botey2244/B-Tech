import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../models/product.dart';
import '../state/product_provider.dart';
import '../state/wishlist_provider.dart';

import 'notification_screen.dart';
import 'product_detail_screen.dart';

import 'package:firebase_database/firebase_database.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String searchText = '';
  String selectedCategory = 'All';
  bool _loadedArgument = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loadedArgument) {
      final argument = ModalRoute.of(context)?.settings.arguments;

      if (argument is String && categories.contains(argument)) {
        selectedCategory = argument;
      }

      _loadedArgument = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool matchCategory(Product product) {
    if (selectedCategory == 'All') return true;
    return product.category.toLowerCase() == selectedCategory.toLowerCase();
  }

  bool matchSearch(Product product) {
    if (searchText.trim().isEmpty) return true;

    final query = searchText.toLowerCase();
    final text =
        '${product.name} ${product.brand} ${product.category} ${product.description}'
            .toLowerCase();

    return text.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final filteredProducts = productProvider.products.where((product) {
      return matchCategory(product) && matchSearch(product);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const _CategoryDrawer(),
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: _Header(),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                onClear: () {
                  setState(() {
                    searchText = '';
                    _searchController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: _CategoryChips(
                categories: categories,
                selectedCategory: selectedCategory,
                onTap: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  Text(
                    selectedCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredProducts.length} items',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CategoryScreen.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: productProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: CategoryScreen.primaryBlue,
                      ),
                    )
                  : filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(26, 0, 26, 18),
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              product: filteredProducts[index],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDrawer extends StatefulWidget {
  const _CategoryDrawer();

  @override
  State<_CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<_CategoryDrawer> {
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
                      color: CategoryScreen.primaryBlue,
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
              onTap: () => Navigator.pop(context),
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
      leading: Icon(icon, color: CategoryScreen.primaryBlue),
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
              child: const Icon(Icons.menu_rounded, size: 27),
            );
          },
        ),
        const Spacer(),
        Row(
          children: [
            Image.asset('assets/images/logo.png', width: 22, height: 22),
            const SizedBox(width: 5),
            const Text(
              'Tech',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
          child: const Icon(Icons.notifications, size: 25),
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
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, size: 21),
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 18),
                )
              : null,
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onTap,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onTap(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: selected
                    ? CategoryScreen.primaryBlue
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white : Colors.black54,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: CategoryScreen.primaryBlue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 1) return;

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
            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
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
