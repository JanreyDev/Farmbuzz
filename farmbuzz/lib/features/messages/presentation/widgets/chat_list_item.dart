import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'chat_mock_data.dart';

class ChatListItem extends StatelessWidget {
  final ChatPreview chat;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isSelected ? AppColors.backgroundLight : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat.avatarUrl),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            chat.name,
            style: TextStyle(
              fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            chat.time,
            style: TextStyle(
              color: chat.isUnread ? AppColors.accentGreen : Colors.grey[500],
              fontSize: 12,
              fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.isUnread ? Colors.black87 : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: chat.isUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (chat.isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
