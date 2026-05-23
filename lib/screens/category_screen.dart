import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
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
    'Desktops',
    'Headphones',
    'Monitors',
    'Laptops',
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

  bool matchCategory(dynamic product) {
    if (selectedCategory == 'All') return true;

    final text = '${product.name} ${product.description}'.toLowerCase();

    if (selectedCategory == 'Laptops') {
      return text.contains('laptop') ||
          text.contains('macbook') ||
          text.contains('lenovo') ||
          text.contains('ideapad');
    }

    if (selectedCategory == 'Desktops') {
      return text.contains('desktop') ||
          text.contains('all-in-one') ||
          text.contains('inspiron');
    }

    if (selectedCategory == 'Headphones') {
      return text.contains('headphone') ||
          text.contains('headphones') ||
          text.contains('noise');
    }

    if (selectedCategory == 'Monitors') {
      return text.contains('monitor') || text.contains('display');
    }

    return true;
  }

  bool matchSearch(dynamic product) {
    if (searchText.trim().isEmpty) return true;

    final query = searchText.toLowerCase();
    final text = '${product.name} ${product.description}'.toLowerCase();

    return text.contains(query);
  }

  void openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                leading: Icon(
                  selectedCategory == category
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: CategoryScreen.primaryBlue,
                ),
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
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
                onFilterTap: openFilterSheet,
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
            const SizedBox(height: 20),
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
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];

                            return _ProductCard(
                              imagePath: product.imageUrl,
                              title: product.name,
                              description: product.description,
                              price: formatPrice(product.price),
                              rating: '4.6 (1,068 reviews)',
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'limpotkolbotey@gmail.com',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 28),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.grid_view_rounded,
              title: 'Categories',
              onTap: () {
                Navigator.pop(context);
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
      leading: Icon(icon, color: CategoryScreen.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
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
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Icon(Icons.menu_rounded, size: 27),
            );
          },
        ),
        const Spacer(),
        Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 5),
            const Text(
              'Tech',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
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
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                border: InputBorder.none,
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: const Icon(Icons.close, size: 18),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFilterTap,
          child: const Icon(
            Icons.filter_alt_outlined,
            size: 27,
            color: Colors.black54,
          ),
        ),
      ],
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
      height: 28,
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
                    fontSize: 10,
                    color: selected ? Colors.white : Colors.black54,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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

  @override
  Widget build(BuildContext context) {
    final product = productFromDisplayData(
      title: title,
      description: description,
      price: price,
      imagePath: imagePath,
    );

    final isWishlisted =
        context.watch<WishlistProvider>().containsProduct(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.productDetail,
          arguments: ProductDetailData(
            imagePath: imagePath,
            title: title,
            description: description,
            price: price,
            rating: rating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 7.8,
                    color: Colors.black87,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: $price',
                  style: const TextStyle(
                    color: CategoryScreen.primaryBlue,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  context.read<WishlistProvider>().toggleProduct(product);
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
