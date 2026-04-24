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

final List<NotificationModel> mockNotifications = [
  NotificationModel(
    id: '1',
    userName: 'Allyssa Rose Jemino',
    action: 'reacted to your post',
    time: '2h ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=allyssa',
    isUnread: true,
    category: 'Social',
    group: 'TODAY',
  ),
  NotificationModel(
    id: '2',
    userName: 'TRIXIE',
    action: 'replied to your comment',
    time: '5h ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=trixie',
    isUnread: true,
    category: 'Social',
    group: 'TODAY',
  ),
  NotificationModel(
    id: '3',
    userName: 'Allyssa Rose Jemino',
    action: 'reacted to your post',
    time: '1d ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=allyssa',
    isUnread: true,
    category: 'Social',
    group: 'THIS WEEK',
  ),
  NotificationModel(
    id: '4',
    userName: 'TRIXIE',
    action: 'reacted to your post',
    time: '1d ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=trixie',
    isUnread: true,
    category: 'Social',
    group: 'THIS WEEK',
  ),
  NotificationModel(
    id: '5',
    userName: 'Jerry',
    action: 'replied to your comment',
    time: '1d ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=jerry',
    isUnread: true,
    category: 'Social',
    group: 'THIS WEEK',
  ),
  NotificationModel(
    id: '6',
    userName: 'Jerry',
    action: 'reacted to your post',
    time: '1d ago',
    avatarUrl: 'https://i.pravatar.cc/150?u=jerry',
    isUnread: true,
    category: 'Social',
    group: 'THIS WEEK',
  ),
];
