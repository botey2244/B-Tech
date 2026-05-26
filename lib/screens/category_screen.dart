import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  bool _matchCategory(Product product) {
    if (selectedCategory == 'All') return true;
    return product.category.toLowerCase() == selectedCategory.toLowerCase();
  }

  bool _matchSearch(Product product) {
    final search = searchText.trim().toLowerCase();

    if (search.isEmpty) return true;

    return product.name.toLowerCase().contains(search) ||
        product.description.toLowerCase().contains(search) ||
        product.brand.toLowerCase().contains(search) ||
        product.category.toLowerCase().contains(search);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final filteredProducts = productProvider.products.where((product) {
      return _matchCategory(product) && _matchSearch(product);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SizedBox(
        width: 260,
        child: _CategoryDrawer(),
      ),
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
              const SizedBox(height: 28),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              _CategoryList(
                categories: categories,
                selectedCategory: selectedCategory,
                onTap: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    selectedCategory == 'All'
                        ? 'All Products'
                        : selectedCategory,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredProducts.length} items',
                    style: const TextStyle(
                      color: CategoryScreen.primaryBlue,
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
                    color: CategoryScreen.primaryBlue,
                  ),
                )
              else if (filteredProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    childAspectRatio: 0.68,
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
    final savedImage = prefs.getString('profile_image') ??
        prefs.getString('profileImageBase64');

    if (savedImage != null && savedImage.isNotEmpty && mounted) {
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
              radius: 45,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFE7D9FF),
                backgroundImage: profileImageBytes != null
                    ? MemoryImage(profileImageBytes!)
                    : null,
                child: profileImageBytes == null
                    ? const Icon(
                        Icons.person,
                        size: 42,
                        color: CategoryScreen.primaryBlue,
                      )
                    : null,
              ),
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
              child: const Icon(Icons.menu_rounded, size: 24),
            );
          },
        ),
        const Spacer(),
        Row(
          children: [
            Image.asset('assets/images/logo.png', width: 30, height: 30),
            const Text(
              'Tech',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const Spacer(),
        const _NotificationBell(),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.notifications_rounded, size: 28),
        onPressed: () {
          Navigator.pushNamed(context, Routes.notifications);
        },
      );
    }

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref('users/${user.uid}/notifications')
          .onValue,
      builder: (context, snapshot) {
        int unreadCount = 0;

        final value = snapshot.data?.snapshot.value;

        if (value is Map) {
          for (final item in value.values) {
            if (item is Map) {
              final data = Map<String, dynamic>.from(item);
              final isRead = data['isRead'] == true || data['read'] == true;

              if (!isRead) {
                unreadCount++;
              }
            }
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, Routes.notifications);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CategoryScreen.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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

class _CategoryList extends StatelessWidget {
  const _CategoryList({
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
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onTap(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: selected
                    ? CategoryScreen.primaryBlue
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.transparent,
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
                              color: CategoryScreen.primaryBlue,
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
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isWishlisted ? Colors.red : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Price: ${formatPrice(product.price)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CategoryScreen.primaryBlue,
                          fontSize: 11,
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
