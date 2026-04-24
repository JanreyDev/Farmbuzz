import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isEmoji;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=chelsea'),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isEmoji ? 4 : 16,
                    vertical: isEmoji ? 4 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe 
                      ? (isEmoji ? Colors.transparent : AppColors.accentGreen) 
                      : (isEmoji ? Colors.transparent : AppColors.backgroundLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe 
                        ? (isEmoji ? Colors.black : Colors.white) 
                        : Colors.black87,
                      fontSize: isEmoji ? 32 : 14,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                const Icon(Icons.done_all, size: 14, color: Colors.blue),
              ],
            ],
          ),
          if (time.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isMe ? 0 : 36,
                right: isMe ? 24 : 0,
              ),
              child: Text(
                time,
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
