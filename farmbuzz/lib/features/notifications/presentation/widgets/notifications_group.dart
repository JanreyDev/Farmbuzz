import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'notification_mock_data.dart';
import 'notification_list_item.dart';

class NotificationsGroup extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationsGroup({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          return NotificationListItem(notification: notifications[index]);
        },
      ),
    );
  }
}
