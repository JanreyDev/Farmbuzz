class NotificationModel {
  final String id;
  final String userName;
  final String action;
  final String time;
  final String avatarUrl;
  final bool isUnread;
  final String category; // 'Social', 'System'
  final String group; // 'TODAY', 'THIS WEEK'

  NotificationModel({
    required this.id,
    required this.userName,
    required this.action,
    required this.time,
    required this.avatarUrl,
    required this.isUnread,
    required this.category,
    required this.group,
  });
}

final List<NotificationModel> mockNotifications = [];
