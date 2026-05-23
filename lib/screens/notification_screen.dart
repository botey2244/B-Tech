import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool isSelectMode = false;
  String searchText = '';

  final List<NotificationItemModel> notifications = [
    NotificationItemModel(
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFF7897D8),
      bgColor: const Color(0xFFDCE8FF),
      title: 'Receipt Generated',
      message: 'Your receipt for 4 items is ready.',
      time: '3m ago',
    ),
    NotificationItemModel(
      icon: Icons.receipt_outlined,
      iconColor: const Color(0xFF4CAF50),
      bgColor: const Color(0xFFC9F2C3),
      title: 'Receipt Ready to Use',
      message: 'Use this receipt to give to the seller',
      time: '4m ago',
    ),
    NotificationItemModel(
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: Colors.orange,
      bgColor: const Color(0xFFFFF0C8),
      title: 'Contact Seller Reminder',
      message: 'Please contact the seller on Facebook.',
      time: '5m ago',
    ),
    NotificationItemModel(
      icon: Icons.local_offer_rounded,
      iconColor: const Color(0xFF5B4DD6),
      bgColor: const Color(0xFFEAF2FF),
      title: 'Special Offer',
      message: 'Get 10% OFF on your next receipt',
      time: '6m ago',
    ),
  ];

  List<NotificationItemModel> get filteredNotifications {
    if (searchText.trim().isEmpty) {
      return notifications;
    }

    final query = searchText.toLowerCase();

    return notifications.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          item.time.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void toggleSelectMode() {
    setState(() {
      isSelectMode = !isSelectMode;

      if (!isSelectMode) {
        for (final item in notifications) {
          item.isSelected = false;
        }
      }
    });
  }

  void markSelectedAsRead() {
    setState(() {
      for (final item in notifications) {
        if (item.isSelected) {
          item.isUnread = false; // blue dot disappears
          item.isSelected = false;
        }
      }

      isSelectMode = false;
    });
  }

  void deleteSelected() {
    setState(() {
      notifications.removeWhere((item) => item.isSelected);
      isSelectMode = false;
    });
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
                onTap: () {
                  setState(() {
                    item.isUnread = false; // blue dot disappears
                  });
                  Navigator.pop(context);
                },
              ),
              _BottomOption(
                icon: Icons.archive_outlined,
                title: 'Archive',
                color: Colors.black,
                onTap: () {
                  setState(() {
                    notifications.remove(item);
                  });
                  Navigator.pop(context);
                },
              ),
              _BottomOption(
                icon: Icons.delete_outline,
                title: 'Delete',
                color: Colors.red,
                onTap: () {
                  setState(() {
                    notifications.remove(item);
                  });
                  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = filteredNotifications;

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
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
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
                    onTap: markSelectedAsRead,
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
                    onTap: deleteSelected,
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
              child: visibleNotifications.isEmpty
                  ? const _NoSearchResult()
                  : ListView.builder(
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
                          onTap: () {
                            if (isSelectMode) {
                              setState(() {
                                item.isSelected = !item.isSelected;
                              });
                            }
                          },
                          onMoreTap: () {
                            showMoreOptions(item);
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
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = true,
    this.isSelected = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String message;
  final String time;

  bool isUnread;
  bool isSelected;
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.item,
    required this.isSelectMode,
    required this.onTap,
    required this.onMoreTap,
  });

  final NotificationItemModel item;
  final bool isSelectMode;
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
                item.isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
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
            CircleAvatar(
              radius: 29,
              backgroundColor: item.bgColor,
              child: Icon(item.icon, color: item.iconColor, size: 28),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onMoreTap,
                  child: const Icon(Icons.more_horiz, size: 24),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.chevron_right_rounded, size: 28),
              ],
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
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
