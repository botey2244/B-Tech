import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color background = Color(0xFFF5F6FA);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();
  final productSearchController = TextEditingController();

  String selectedTab = 'Dashboard';
  String productSearchText = '';

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageController.dispose();
    productSearchController.dispose();
    super.dispose();
  }

  String makeId(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  List<Map<String, dynamic>> parseMap(dynamic value) {
    if (value is! Map) return [];

    final list = <Map<String, dynamic>>[];

    value.forEach((key, item) {
      if (item is Map) {
        final data = Map<String, dynamic>.from(item);
        data['id'] = key.toString();
        list.add(data);
      }
    });

    return list;
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final brand = brandController.text.trim();
    final category = categoryController.text.trim();
    final description = descriptionController.text.trim();
    final imageUrl = imageController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;

    if (name.isEmpty || category.isEmpty || price <= 0) {
      showMessage('Please fill product name, category and valid price.');
      return;
    }

    final id = makeId(name);

    await _database.ref('products/$id').set({
      'name': name,
      'brand': brand.isEmpty ? 'Unknown' : brand,
      'category': category,
      'description': description.isEmpty ? 'No description' : description,
      'price': price,
      'imageUrl': imageUrl.isEmpty ? 'assets/images/image.png' : imageUrl,
      'rating': 0,
      'reviewCount': 0,
      'soldCount': 0,
      'createdAt': ServerValue.timestamp,
    });

    nameController.clear();
    brandController.clear();
    categoryController.clear();
    descriptionController.clear();
    priceController.clear();
    imageController.clear();

    showMessage('Product uploaded successfully.');
  }

  Future<void> deleteProduct(String id) async {
    await _database.ref('products/$id').remove();
    showMessage('Product deleted.');
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminScreen.background,
      body: SafeArea(
        child: Column(
          children: [
            _AdminHeader(
              selectedTab: selectedTab,
              onTabChanged: (tab) {
                setState(() => selectedTab = tab);
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: selectedTab == 'Products'
                    ? buildProducts()
                    : selectedTab == 'Orders'
                        ? buildOrders()
                        : selectedTab == 'Users'
                            ? buildUsers()
                            : buildDashboard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboard() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database.ref().onValue,
      builder: (context, snapshot) {
        final root = snapshot.data?.snapshot.value;
        final data = root is Map ? Map<String, dynamic>.from(root) : {};

        final products = parseMap(data['products']);
        final users = parseMap(data['users']);

        int orderCount = 0;
        double revenue = 0;
        final recentOrders = <Map<String, dynamic>>[];

        for (final user in users) {
          final userOrders = user['orders'];
          if (userOrders is Map) {
            orderCount += userOrders.length;

            userOrders.forEach((orderId, orderValue) {
              if (orderValue is Map) {
                final order = Map<String, dynamic>.from(orderValue);
                order['orderId'] = orderId.toString();
                order['userId'] = user['id']?.toString() ?? 'Unknown';
                revenue += double.tryParse(order['total'].toString()) ?? 0;
                recentOrders.add(order);
              }
            });
          }
        }

        recentOrders.sort((a, b) {
          final aTime = (a['createdAt'] as num?)?.toInt() ?? 0;
          final bTime = (b['createdAt'] as num?)?.toInt() ?? 0;
          return bTime.compareTo(aTime);
        });

        return ListView(
          key: const ValueKey('dashboard'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Monitor your store performance and manage everything easily.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _StatCard(
              title: 'Products',
              value: products.length.toString(),
              icon: Icons.inventory_2_rounded,
              color: AdminScreen.primaryBlue,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Users',
              value: users.length.toString(),
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF0E9F6E),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Orders',
              value: orderCount.toString(),
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Revenue',
              value: '\$${revenue.toStringAsFixed(2)}',
              icon: Icons.attach_money_rounded,
              color: const Color(0xFFE91E63),
            ),
            const SizedBox(height: 22),
            _HeroAdminCard(
              onPressed: () {
                setState(() => selectedTab = 'Products');
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (recentOrders.isEmpty)
              const _EmptyBox(text: 'No recent orders yet.')
            else
              ...recentOrders.take(3).map(
                    (order) => _OrderAdminCard(order: order),
                  ),
          ],
        );
      },
    );
  }

  Widget buildProducts() {
    return ListView(
      key: const ValueKey('products'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        const Text(
          'Product Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Search, add, edit, and delete products.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _SearchBox(
          controller: productSearchController,
          onChanged: (value) {
            setState(() => productSearchText = value);
          },
        ),
        const SizedBox(height: 20),
        _SectionBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Product',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _Input(controller: nameController, hint: 'Product name'),
              _Input(controller: brandController, hint: 'Brand'),
              _Input(controller: categoryController, hint: 'Category'),
              _Input(controller: descriptionController, hint: 'Description'),
              _Input(controller: priceController, hint: 'Price', number: true),
              _Input(
                controller: imageController,
                hint: 'Image path: assets/images/image45.png',
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: addProduct,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text(
                  'Upload Product',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminScreen.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Products List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<DatabaseEvent>(
          stream: _database.ref('products').onValue,
          builder: (context, snapshot) {
            final products = parseMap(snapshot.data?.snapshot.value);
            final query = productSearchText.toLowerCase();

            final filteredProducts = products.where((product) {
              final text =
                  '${product['name']} ${product['brand']} ${product['category']}'
                      .toLowerCase();
              return text.contains(query);
            }).toList();

            if (filteredProducts.isEmpty) {
              return const _EmptyBox(text: 'No products found.');
            }

            return Column(
              children: filteredProducts.map((product) {
                return _ProductAdminCard(
                  product: product,
                  onDelete: () => deleteProduct(product['id'].toString()),
                  onUpdate: () => _showEditProductSheet(product),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showEditProductSheet(Map<String, dynamic> product) {
    final editName = TextEditingController(text: product['name']?.toString());
    final editBrand = TextEditingController(text: product['brand']?.toString());
    final editCategory =
        TextEditingController(text: product['category']?.toString());
    final editDescription =
        TextEditingController(text: product['description']?.toString());
    final editPrice = TextEditingController(text: product['price']?.toString());
    final editImage =
        TextEditingController(text: product['imageUrl']?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _Input(controller: editName, hint: 'Name'),
                _Input(controller: editBrand, hint: 'Brand'),
                _Input(controller: editCategory, hint: 'Category'),
                _Input(controller: editDescription, hint: 'Description'),
                _Input(controller: editPrice, hint: 'Price', number: true),
                _Input(controller: editImage, hint: 'Image path'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await _database.ref('products/${product['id']}').update({
                      'name': editName.text.trim(),
                      'brand': editBrand.text.trim(),
                      'category': editCategory.text.trim(),
                      'description': editDescription.text.trim(),
                      'price': double.tryParse(editPrice.text.trim()) ?? 0,
                      'imageUrl': editImage.text.trim(),
                      'updatedAt': ServerValue.timestamp,
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    showMessage('Product updated.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminScreen.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOrders() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database.ref('users').onValue,
      builder: (context, snapshot) {
        final users = parseMap(snapshot.data?.snapshot.value);
        final orders = <Map<String, dynamic>>[];

        for (final user in users) {
          final userOrders = user['orders'];
          if (userOrders is Map) {
            userOrders.forEach((orderId, orderValue) {
              if (orderValue is Map) {
                final order = Map<String, dynamic>.from(orderValue);
                order['orderId'] = orderId.toString();
                order['userId'] = user['id']?.toString() ?? 'Unknown';
                orders.add(order);
              }
            });
          }
        }

        return ListView(
          key: const ValueKey('orders'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            const Text(
              'User Orders',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Track all customer orders from Firebase.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (orders.isEmpty)
              const _EmptyBox(text: 'No orders found.')
            else
              ...orders.map((order) => _OrderAdminCard(order: order)),
          ],
        );
      },
    );
  }

  Widget buildUsers() {
    return StreamBuilder<DatabaseEvent>(
      stream: _database.ref('users').onValue,
      builder: (context, snapshot) {
        final users = parseMap(snapshot.data?.snapshot.value);

        return ListView(
          key: const ValueKey('users'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            const Text(
              'Users',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'View registered customer accounts.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const _EmptyBox(text: 'No users found.')
            else
              ...users.map((user) {
                final profile = user['profile'];

                final profileMap = profile is Map
                    ? Map<String, dynamic>.from(profile)
                    : <String, dynamic>{};

                final name = profileMap['name']?.toString() ??
                    profileMap['fullName']?.toString() ??
                    profileMap['username']?.toString() ??
                    profileMap['displayName']?.toString() ??
                    user['name']?.toString() ??
                    user['email']?.toString() ??
                    'Unknown User';

                final email = profileMap['email']?.toString() ??
                    user['email']?.toString() ??
                    user['userEmail']?.toString() ??
                    user['gmail']?.toString() ??
                    user['id']?.toString() ??
                    'No email';

                return _UserAdminCard(
                  name: name,
                  email: email,
                );
              }),
          ],
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'name': 'Dashboard', 'icon': Icons.dashboard_rounded},
      {'name': 'Products', 'icon': Icons.inventory_2_rounded},
      {'name': 'Orders', 'icon': Icons.receipt_long_rounded},
      {'name': 'Users', 'icon': Icons.people_alt_rounded},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1607B8),
                      Color(0xFF4B35FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'B Tech Admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Store management center',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final name = tab['name'] as String;
                final icon = tab['icon'] as IconData;
                final selected = name == selectedTab;

                return GestureDetector(
                  onTap: () => onTabChanged(name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? AdminScreen.primaryBlue
                          : const Color(0xFFF3F4F8),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AdminScreen.primaryBlue
                                    .withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: selected ? Colors.white : Colors.black45,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          name,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAdminCard extends StatelessWidget {
  const _HeroAdminCard({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1607B8),
            Color(0xFF4B35FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AdminScreen.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 14),
          const Text(
            'Store Control Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add products, update prices, check orders and manage users from one place.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AdminScreen.primaryBlue,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: AdminScreen.primaryBlue,
          ),
          hintText: 'Search products by name, brand, category...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.number = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F7FA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onDelete,
    required this.onUpdate,
  });

  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product['imageUrl']?.toString() ?? 'assets/images/image.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: AdminScreen.primaryBlue,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']?.toString() ?? 'Unknown Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${product['brand'] ?? 'Unknown'} • ${product['category'] ?? 'Unknown'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${product['price'] ?? 0}',
                  style: const TextStyle(
                    color: AdminScreen.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onUpdate,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderAdminCard extends StatelessWidget {
  const _OrderAdminCard({
    required this.order,
  });

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final total = order['total'] ?? 0;
    final status = order['status']?.toString() ?? 'Pending';
    final items = order['items'];

    int itemCount = 0;
    if (items is List) {
      itemCount = items.length;
    } else if (items is Map) {
      itemCount = items.length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order: ${order['orderId'] ?? 'Unknown'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'User: ${order['userId'] ?? 'Unknown'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Total: \$$total',
                style: const TextStyle(
                  color: AdminScreen.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '$itemCount items',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AdminScreen.primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAdminCard extends StatelessWidget {
  const _UserAdminCard({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFF1EDFF),
            child: Icon(
              Icons.person_rounded,
              color: AdminScreen.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
