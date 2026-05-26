import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../core/product_helpers.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../state/cart_provider.dart';

import 'contact_seller_screen.dart';
import 'product_detail_screen.dart';
import 'receipt_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<String> selectedIds = {};
  bool isCreatingOrder = false;

  bool isSelected(String id) {
    return selectedIds.contains(id);
  }

  void toggleSelect(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  void toggleSelectAll(List<CartItem> items) {
    setState(() {
      if (selectedIds.length == items.length) {
        selectedIds.clear();
      } else {
        selectedIds.clear();

        for (final item in items) {
          selectedIds.add(item.product.id);
        }
      }
    });
  }

  void deleteSelected(BuildContext context) {
    final cart = context.read<CartProvider>();

    for (final id in selectedIds.toList()) {
      cart.removeProduct(id);
    }

    setState(() {
      selectedIds.clear();
    });
  }

  Future<void> createReceipt(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final items = cart.items;

    if (items.isEmpty || isCreatingOrder) return;

    setState(() {
      isCreatingOrder = true;
    });

    const shipping = 2.0;
    final subtotal = cart.totalPrice;
    final total = subtotal + shipping;

    final orderId = await OrderService().createOrder(
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
    );

    if (!mounted) return;

    setState(() {
      isCreatingOrder = false;
    });

    if (orderId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please login before creating receipt.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    await cart.clearCart();

    if (!mounted) return;
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    final allSelected = items.isNotEmpty && selectedIds.length == items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 92),
          child: Column(
            children: [
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFECE6FF),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: CartScreen.primaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                          'Review your items and proceed to checkout',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
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
                    onTap: items.isEmpty ? null : () => toggleSelectAll(items),
                    child: Icon(
                      allSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color:
                          allSelected ? CartScreen.primaryBlue : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: items.isEmpty ? null : () => toggleSelectAll(items),
                    child: const Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: selectedIds.isEmpty
                        ? null
                        : () => deleteSelected(context),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedIds.isEmpty
                            ? Colors.red.shade200
                            : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (items.isEmpty)
                const _EmptyCart()
              else
                ...items.map(
                  (item) => _CartItem(
                    item: item,
                    selected: isSelected(item.product.id),
                    onSelect: () => toggleSelect(item.product.id),
                  ),
                ),
              const SizedBox(height: 18),
              _PriceSummary(
                subtotal: cart.totalPrice,
                itemCount: items.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: items.isEmpty || isCreatingOrder
                            ? null
                            : () => createReceipt(context),
                        icon: isCreatingOrder
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.receipt_long_outlined),
                        label: Text(
                          isCreatingOrder ? 'Saving...' : 'Receipt',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CartScreen.primaryBlue,
                          side: const BorderSide(
                            color: CartScreen.primaryBlue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ContactSellerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Contact Seller'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CartScreen.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.item,
    required this.selected,
    required this.onSelect,
  });

  final CartItem item;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final price = formatPrice(product.price);

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? CartScreen.primaryBlue : const Color(0xFFE5E5E5),
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onSelect,
              child: Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: selected ? CartScreen.primaryBlue : Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              product.imageUrl,
              width: 70,
              height: 70,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 4),
                  Text(
                    'Price: $price',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CartScreen.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<CartProvider>().removeProduct(product.id);
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _QuantityControl(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.item,
  });

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = item.product;

    return Container(
      width: 72,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              cart.removeOneProduct(product.id);
            },
            child: const Icon(
              Icons.remove_rounded,
              color: CartScreen.primaryBlue,
              size: 18,
            ),
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () {
              cart.addProduct(product);
            },
            child: const Icon(
              Icons.add_rounded,
              color: CartScreen.primaryBlue,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.subtotal,
    required this.itemCount,
  });

  final double subtotal;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    const shipping = 2.0;
    final total = subtotal == 0 ? 0.0 : subtotal + shipping;

    return Column(
      children: [
        _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
        const SizedBox(height: 10),
        _SummaryRow(
          label: 'Shipping',
          value: subtotal == 0 ? formatPrice(0) : formatPrice(shipping),
          green: true,
        ),
        const SizedBox(height: 10),
        _SummaryRow(label: 'Total items', value: '$itemCount items'),
        const SizedBox(height: 12),
        const Divider(color: Colors.black54),
        const SizedBox(height: 10),
        _SummaryRow(
          label: 'Total',
          value: formatPrice(total),
          bold: true,
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

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
            Icons.shopping_cart_outlined,
            color: CartScreen.primaryBlue,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No cart items yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add products to your cart and they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.green = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: green ? Colors.green : Colors.black,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: CartScreen.primaryBlue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 2) return;

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
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
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
