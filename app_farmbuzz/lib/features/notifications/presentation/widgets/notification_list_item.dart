import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/network/media_proxy.dart';
import 'notification_mock_data.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationListItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: safeNetworkImage(notification.avatarUrl),
            child: safeNetworkImage(notification.avatarUrl) == null
                ? Text(notification.userName.isNotEmpty ? notification.userName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    children: [
                      TextSpan(
                        text: notification.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: notification.action),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.time,
                  style: const TextStyle(color: AppColors.accentGreen, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (notification.isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
