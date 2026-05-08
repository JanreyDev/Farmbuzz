import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/notifications/presentation/widgets/notifications_group.dart';
import 'package:farmbuzz/features/notifications/presentation/widgets/notification_mock_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedMainFilter = 'All';
  String selectedSubFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = mockNotifications.where((notification) {
      final mainOk = selectedMainFilter == 'All' ||
          notification.category == selectedMainFilter;
      final subOk = selectedSubFilter != 'Unread' || notification.isUnread;
      return mainOk && subOk;
    }).toList();
    final unreadCount =
        visibleNotifications.where((notification) => notification.isUnread).length;
    final todayNotifications = visibleNotifications
        .where((notification) => notification.group == 'TODAY')
        .toList();
    final thisWeekNotifications = visibleNotifications
        .where((notification) => notification.group == 'THIS WEEK')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats and Mark as read
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unreadCount > 0 ? '$unreadCount new' : 'No new notifications',
                        style: const TextStyle(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check, size: 16, color: Color(0xFF1AAE50)),
                        label: const Text(
                          'Mark all as read',
                          style: TextStyle(color: Color(0xFF1AAE50), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          surfaceTintColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Filters
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: visibleNotifications.length,
                        isActive: selectedMainFilter == 'All',
                        onTap: () => setState(() => selectedMainFilter = 'All'),
                      ),
                      _FilterChip(
                        label: 'Social',
                        count: visibleNotifications
                            .where((notification) => notification.category == 'Social')
                            .length,
                        isActive: selectedMainFilter == 'Social',
                        onTap: () => setState(() => selectedMainFilter = 'Social'),
                      ),
                      _FilterChip(
                        label: 'System',
                        count: visibleNotifications
                            .where((notification) => notification.category == 'System')
                            .length,
                        isActive: selectedMainFilter == 'System',
                        onTap: () => setState(() => selectedMainFilter = 'System'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Sub Filters
                  Row(
                    children: [
                      _SubFilterChip(
                        label: 'All',
                        isActive: selectedSubFilter == 'All',
                        onTap: () => setState(() => selectedSubFilter = 'All'),
                      ),
                      _SubFilterChip(
                        label: 'Unread - $unreadCount',
                        isActive: selectedSubFilter == 'Unread',
                        onTap: () => setState(() => selectedSubFilter = 'Unread'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (visibleNotifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                child: Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              if (todayNotifications.isNotEmpty) ...[
                const SectionHeader(title: 'TODAY'),
                NotificationsGroup(notifications: todayNotifications),
              ],
              if (thisWeekNotifications.isNotEmpty) ...[
                const SectionHeader(title: 'THIS WEEK'),
                NotificationsGroup(notifications: thisWeekNotifications),
              ],
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SubFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
