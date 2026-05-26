import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/routes.dart';
import 'order_history_screen.dart';
import 'receipt_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Uint8List? _profileImageBytes;

  bool _hasUnsavedProfileImage = false;
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  String _name = 'Botey';
  String _email = 'lim.potklbotey25@kit.edu.kh';
  String _location = 'Phnom Penh, Koh Pich';

  User? get _currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _currentUser;

    if (user == null) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final snapshot = await _database.ref('users/${user.uid}/profile').get();

      final value = snapshot.value;
      final data = value is Map ? Map<String, dynamic>.from(value) : null;

      final savedImage = data?['profileImageBase64'] as String?;

      if (savedImage != null && savedImage.isNotEmpty) {
        _profileImageBytes = base64Decode(savedImage);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final localImage = prefs.getString('profile_image');

        if (localImage != null && localImage.isNotEmpty) {
          _profileImageBytes = base64Decode(localImage);
        }
      }

      if (!mounted) return;

      setState(() {
        _name = (data?['name'] as String?)?.trim().isNotEmpty == true
            ? data!['name'] as String
            : user.displayName ?? _name;

        _email = (data?['email'] as String?)?.trim().isNotEmpty == true
            ? data!['email'] as String
            : user.email ?? _email;

        _location = (data?['location'] as String?)?.trim().isNotEmpty == true
            ? data!['location'] as String
            : _location;

        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
      });

      _showMessage('Could not load profile from Firebase.');
    }
  }

  Future<void> _saveProfileImage() async {
    final user = _currentUser;
    if (user == null || _profileImageBytes == null) return;

    final base64Image = base64Encode(_profileImageBytes!);

    await _database.ref('users/${user.uid}/profile').update({
      'profileImageBase64': base64Image,
      'updatedAt': ServerValue.timestamp,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', base64Image);

    if (!mounted) return;

    setState(() {
      _hasUnsavedProfileImage = false;
    });

    _showMessage('Profile photo saved.');
  }

  Future<void> _saveProfileFields() async {
    final user = _currentUser;
    if (user == null) return;

    await _database.ref('users/${user.uid}/profile').update({
      'uid': user.uid,
      'name': _name,
      'email': _email,
      'location': _location,
      'updatedAt': ServerValue.timestamp,
    });

    if (user.displayName != _name) {
      await user.updateDisplayName(_name);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    setState(() {
      _profileImageBytes = bytes;
      _hasUnsavedProfileImage = true;
    });
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final locationController = TextEditingController(text: _location);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileTextField(
                    controller: nameController,
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTextField(
                    controller: locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _name = nameController.text.trim();
                              _email = emailController.text.trim();
                              _location = locationController.text.trim();
                              _isSavingProfile = true;
                            });

                            Navigator.pop(context);

                            _saveProfileFields().then((_) {
                              if (!mounted) return;

                              setState(() {
                                _isSavingProfile = false;
                              });

                              _showMessage('Profile saved.');
                            }).catchError((_) {
                              if (!mounted) return;

                              setState(() {
                                _isSavingProfile = false;
                              });

                              _showMessage('Could not save profile.');
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProfileScreen.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.register,
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  DatabaseReference? _ordersRef() {
    final user = _currentUser;
    if (user == null) return null;
    return _database.ref('users/${user.uid}/orders');
  }

  DatabaseReference? _wishlistRef() {
    final user = _currentUser;
    if (user == null) return null;
    return _database.ref('users/${user.uid}/wishlist');
  }

  @override
  Widget build(BuildContext context) {
    final ordersRef = _ordersRef();
    final wishlistRef = _wishlistRef();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _editProfile,
                    child: const Icon(Icons.edit_square, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (_isLoadingProfile)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: ProfileScreen.primaryBlue,
                  ),
                )
              else
                _ProfileHeader(
                  name: _name,
                  email: _email,
                  location: _location,
                  profileImageBytes: _profileImageBytes,
                  onPickImage: _pickImage,
                ),
              if (_isSavingProfile)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    color: ProfileScreen.primaryBlue,
                    minHeight: 2,
                  ),
                ),
              if (_hasUnsavedProfileImage) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfileImage,
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text('Save Profile Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileScreen.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _FirebaseCountCard(
                      ref: ordersRef,
                      icon: Icons.shopping_bag_outlined,
                      label: 'order',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FirebaseCountCard(
                      ref: wishlistRef,
                      icon: Icons.favorite_border_rounded,
                      label: 'wishlist',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 16,
                        color: ProfileScreen.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _RecentOrdersList(
                ordersRef: ordersRef,
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOrdersList extends StatelessWidget {
  const _RecentOrdersList({
    required this.ordersRef,
  });

  final DatabaseReference? ordersRef;

  @override
  Widget build(BuildContext context) {
    if (ordersRef == null) {
      return const Text('Please login to see orders.');
    }

    return StreamBuilder<DatabaseEvent>(
      stream: ordersRef!.orderByChild('createdAt').limitToLast(5).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong loading orders.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(
              color: ProfileScreen.primaryBlue,
            ),
          );
        }

        final value = snapshot.data?.snapshot.value;

        if (value == null || value is! Map) {
          return const Text('No recent orders yet.');
        }

        final orders = <Map<String, dynamic>>[];

        value.forEach((key, orderValue) {
          if (orderValue is Map) {
            final data = Map<String, dynamic>.from(orderValue);
            data['id'] = key.toString();
            orders.add(data);
          }
        });

        orders.sort((a, b) {
          final aTime = (a['createdAt'] as num?)?.toInt() ?? 0;
          final bTime = (b['createdAt'] as num?)?.toInt() ?? 0;
          return bTime.compareTo(aTime);
        });

        return Column(
          children: orders.map((order) {
            return _OrderCard(order: order);
          }).toList(),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
  });

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? '';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final createdAt = order['createdAt'];

    final items = _parseItems(order['items']);

    final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};

    final imageUrl =
        firstItem['imageUrl']?.toString() ?? 'assets/images/image.png';
    final name = firstItem['name']?.toString() ?? 'Order';

    final quantity = items.fold<int>(0, (sum, item) {
      final q = item['quantity'];
      if (q is num) return sum + q.toInt();
      return sum;
    });

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(orderId: orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset(
              imageUrl,
              width: 72,
              height: 52,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 72,
                  height: 52,
                  color: const Color(0xFFF2F2F2),
                  child: const Icon(Icons.shopping_bag_outlined),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$quantity item${quantity > 1 ? 's' : ''} • ${_formatDate(createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  static List<Map<String, dynamic>> _parseItems(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! num) return 'No date';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _FirebaseCountCard extends StatelessWidget {
  const _FirebaseCountCard({
    required this.ref,
    required this.icon,
    required this.label,
  });

  final DatabaseReference? ref;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: ref?.onValue,
      builder: (context, snapshot) {
        int count = 0;

        final value = snapshot.data?.snapshot.value;
        if (value is Map) {
          count = value.length;
        }

        return _StatCard(
          icon: icon,
          number: count.toString(),
          label: label,
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.location,
    required this.profileImageBytes,
    required this.onPickImage,
  });

  final String name;
  final String email;
  final String location;
  final Uint8List? profileImageBytes;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final ImageProvider? profileImageProvider =
        profileImageBytes != null ? MemoryImage(profileImageBytes!) : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: ProfileScreen.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 43,
                  backgroundColor: const Color(0xFFE7D9FF),
                  backgroundImage: profileImageProvider,
                  child: profileImageBytes == null
                      ? const Icon(
                          Icons.person,
                          size: 42,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 8,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: ProfileScreen.primaryBlue),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 17,
                      color: ProfileScreen.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'No Name' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  email.isEmpty ? 'No Email' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location.isEmpty ? 'No Location' : location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Joined May, 2026',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: ProfileScreen.primaryBlue,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  final IconData icon;
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFECE6FF),
            child: Icon(
              icon,
              color: ProfileScreen.primaryBlue,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10),
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
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ProfileScreen.primaryBlue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 4) return;

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
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
