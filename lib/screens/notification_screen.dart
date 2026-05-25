import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  bool isSelectMode = false;
  String searchText = '';
  final Set<String> selectedIds = {};

  DatabaseReference? get _notificationRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _database.ref('users/${user.uid}/notifications');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void toggleSelectMode() {
    setState(() {
      isSelectMode = !isSelectMode;
      if (!isSelectMode) selectedIds.clear();
    });
  }

  Future<void> markSelectedAsRead() async {
    final ref = _notificationRef;
    if (ref == null) return;

    for (final id in selectedIds) {
      await ref.child(id).update({'isUnread': false});
    }

    setState(() {
      selectedIds.clear();
      isSelectMode = false;
    });
  }

  Future<void> deleteSelected() async {
    final ref = _notificationRef;
    if (ref == null) return;

    for (final id in selectedIds) {
      await ref.child(id).remove();
    }

    setState(() {
      selectedIds.clear();
      isSelectMode = false;
    });
  }

  Future<void> markOneAsRead(String id) async {
    final ref = _notificationRef;
    if (ref == null) return;
    await ref.child(id).update({'isUnread': false});
  }

  Future<void> deleteOne(String id) async {
    final ref = _notificationRef;
    if (ref == null) return;
    await ref.child(id).remove();
  }

  void showMoreOptions(NotificationItemModel item) {
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
            children: [
              _BottomOption(
                icon: Icons.mark_email_read_outlined,
                title: 'Mark as read',
                color: NotificationScreen.primaryBlue,
                onTap: () async {
                  await markOneAsRead(item.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              _BottomOption(
                icon: Icons.delete_outline,
                title: 'Delete',
                color: Colors.red,
                onTap: () async {
                  await deleteOne(item.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void clearSearch() {
    setState(() {
      _searchController.clear();
      searchText = '';
    });
  }

  List<NotificationItemModel> _filterNotifications(
    List<NotificationItemModel> list,
  ) {
    if (searchText.trim().isEmpty) return list;

    final query = searchText.toLowerCase();

    return list.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          item.time.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ref = _notificationRef;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleSelectMode,
                    child: Text(
                      isSelectMode ? 'Cancel' : 'Select',
                      style: const TextStyle(
                        color: NotificationScreen.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, size: 24),
                    hintText: 'Search notifications...',
                    border: InputBorder.none,
                    suffixIcon: searchText.isNotEmpty
                        ? GestureDetector(
                            onTap: clearSearch,
                            child: const Icon(Icons.close, size: 20),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Row(
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: selectedIds.isEmpty ? null : markSelectedAsRead,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          color: NotificationScreen.primaryBlue,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Read',
                          style: TextStyle(
                            color: NotificationScreen.primaryBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: selectedIds.isEmpty ? null : deleteSelected,
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 5),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ref == null
                  ? const Center(child: Text('Please login first'))
                  : StreamBuilder<DatabaseEvent>(
                      stream: ref.orderByChild('createdAt').onValue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final value = snapshot.data?.snapshot.value;

                        final allNotifications = <NotificationItemModel>[];

                        if (value is Map) {
                          value.forEach((key, data) {
                            final map = Map<String, dynamic>.from(data as Map);

                            allNotifications.add(
                              NotificationItemModel(
                                id: key.toString(),
                                title: map['title'] ?? '',
                                message: map['message'] ?? '',
                                time: _timeAgo(map['createdAt']),
                                isUnread: map['isUnread'] ?? true,
                              ),
                            );
                          });
                        }

                        allNotifications.sort((a, b) => b.id.compareTo(a.id));

                        final visibleNotifications =
                            _filterNotifications(allNotifications);

                        if (visibleNotifications.isEmpty) {
                          return const _NoSearchResult();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 38),
                          itemCount: visibleNotifications.length + 1,
                          itemBuilder: (context, index) {
                            if (index == visibleNotifications.length) {
                              return const _EmptyBottom();
                            }

                            final item = visibleNotifications[index];

                            return _NotificationItem(
                              item: item,
                              isSelectMode: isSelectMode,
                              isSelected: selectedIds.contains(item.id),
                              onTap: () {
                                if (isSelectMode) {
                                  setState(() {
                                    if (selectedIds.contains(item.id)) {
                                      selectedIds.remove(item.id);
                                    } else {
                                      selectedIds.add(item.id);
                                    }
                                  });
                                } else {
                                  markOneAsRead(item.id);
                                }
                              },
                              onMoreTap: () {
                                showMoreOptions(item);
                              },
                            );
                          },
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

class NotificationItemModel {
  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.item,
    required this.isSelectMode,
    required this.isSelected,
    required this.onTap,
    required this.onMoreTap,
  });

  final NotificationItemModel item;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 116),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFD6D6D6)),
          ),
        ),
        child: Row(
          children: [
            if (isSelectMode)
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: NotificationScreen.primaryBlue,
                size: 22,
              )
            else
              CircleAvatar(
                radius: 6,
                backgroundColor: item.isUnread
                    ? NotificationScreen.primaryBlue
                    : Colors.transparent,
              ),
            const SizedBox(width: 18),
            const CircleAvatar(
              radius: 29,
              backgroundColor: Color(0xFFEDE7FF),
              child: Icon(
                Icons.notifications_active_outlined,
                color: NotificationScreen.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.time,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onMoreTap,
              child: const Icon(Icons.more_horiz, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomOption extends StatelessWidget {
  const _BottomOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No notifications found',
        style: TextStyle(
          color: Colors.black45,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyBottom extends StatelessWidget {
  const _EmptyBottom();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 34),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 34, color: Colors.black54),
          SizedBox(height: 16),
          Text(
            'You’re all caught up!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'We’ll notify you when something new arrives.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
