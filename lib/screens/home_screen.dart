import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

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
      drawer: const SizedBox(
        width: 260,
        child: _HomeDrawer(),
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

class _HomeDrawer extends StatefulWidget {
  const _HomeDrawer();

  @override
  State<_HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<_HomeDrawer> {
  Uint8List? profileImageBytes;
  String name = 'Jing Jing';
  String email = 'limpotkolbotey@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      Map<String, dynamic>? data;

      if (user != null) {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${user.uid}/profile')
            .get();
        final value = snapshot.value;
        data = value is Map ? Map<String, dynamic>.from(value) : null;
      }

      final savedImage = data?['profileImageBase64'] as String?;

      if (savedImage != null && savedImage.isNotEmpty) {
        profileImageBytes = base64Decode(savedImage);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final localImage = prefs.getString('profile_image') ??
            prefs.getString('profileImageBase64');

        if (localImage != null && localImage.isNotEmpty) {
          profileImageBytes = base64Decode(localImage);
        }
      }

      if (!mounted) return;

      setState(() {
        name = (data?['name'] as String?)?.trim().isNotEmpty == true
            ? data!['name'] as String
            : user?.displayName ?? name;
        email = (data?['email'] as String?)?.trim().isNotEmpty == true
            ? data!['email'] as String
            : user?.email ?? email;
      });
    } catch (_) {
      if (mounted) setState(() {});
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
                        color: HomeScreen.primaryBlue,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name.isEmpty ? 'No Name' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              email.isEmpty ? 'No Email' : email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
              child: const Icon(Icons.menu_rounded, size: 24),
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
          child: const _NotificationBell(),
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
                    color: HomeScreen.primaryBlue,
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

class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.onShopNowTap});

  final VoidCallback onShopNowTap;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 1);

  int currentIndex = 0;
  Timer? _timer;
  late AnimationController _floatController;
  Animation<double>? _floatAnimation;

  final List<Map<String, String>> banners = [
    {
      'title': 'Power Up\nYour World',
      'subtitle': 'best tech store',
      'button': 'Shop Now',
      'image': 'assets/images/image.png',
    },
    {
      'title': 'Mega Tech\nSale',
      'subtitle': 'up to 30% off laptops',
      'button': 'Buy Now',
      'image': 'assets/images/macbook.png',
    },
    {
      'title': 'Gaming Gear\nDeals',
      'subtitle': 'controllers, mouse pads & more',
      'button': 'Explore',
      'image': 'assets/images/image45.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      final nextIndex = (currentIndex + 1) % banners.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      } else {
        setState(() => currentIndex = nextIndex);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBannerCard(Map<String, String> banner) {
    final isGamingBanner = banner['image'] == 'assets/images/image45.png';
    final imageScale = isGamingBanner ? 1.1 : 1.3;
    final imageWidth = isGamingBanner ? 170.0 : 170.0;
    final imageHeight = isGamingBanner ? 120.0 : 120.0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeScreen.darkPurple,
            Color(0xFF342247),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 148,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner['title']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    banner['subtitle']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: widget.onShopNowTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        banner['button']!,
                        style: const TextStyle(
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
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _floatAnimation ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation?.value ?? 0),
                  child: AnimatedScale(
                    scale: imageScale,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: const Alignment(
                    0.6, 0), // Shift closer to text (was centerRight)
                child: Image.asset(
                  banner['image']!,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.devices_rounded,
                      color: Colors.white,
                      size: 78,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          ClipRect(
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.hardEdge,
              physics: const BouncingScrollPhysics(
                parent: PageScrollPhysics(),
              ),
              itemCount: banners.length,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) {
                return _buildBannerCard(banners[index]);
              },
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentIndex == index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                          color: HomeScreen.primaryBlue,
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

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.onTap,
  });

  final List<String> categories;
  final Function(String) onTap;

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

          return GestureDetector(
            onTap: () => onTap(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: index == 0
                    ? HomeScreen.primaryBlue
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: index == 0 ? Colors.white : Colors.black54,
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
