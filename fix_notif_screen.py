import sys

def modify(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    old_class = '''class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    final items = <_NotifItem>[
      _NotifItem(
        title: 'Aldrin Poultry reacted to your post',
        subtitle:
            '“Nice lineup bro!”',
        time: '2m ago',
        unread: true,
        typeIcon: Icons.thumb_up_alt_rounded,
        iconColor: const Color(0xFF16A34A),
      ),
      _NotifItem(
        title: 'Cebu Breeders Club mentioned you',
        subtitle: 'Check announcements for tomorrow.',
        time: '14m ago',
        unread: true,
        typeIcon: Icons.alternate_email_rounded,
        iconColor: const Color(0xFF2563EB),
      ),
      _NotifItem(
        title: 'Your story got 12 views',
        subtitle: 'Keep sharing updates to grow your reach.',
        time: '1h ago',
        unread: false,
        typeIcon: Icons.visibility_rounded,
        iconColor: const Color(0xFFF59E0B),
      ),
      _NotifItem(
        title: 'Bantay AI replied to your question',
        subtitle: 'Tap to read the full response.',
        time: '3h ago',
        unread: false,
        typeIcon: Icons.smart_toy_rounded,
        iconColor: const Color(0xFF7C3AED),
      ),
      _NotifItem(
        title: 'Jayson sent you a new message',
        subtitle:
            '“Pwede pickup bukas morning.”',
        time: '5h ago',
        unread: false,
        typeIcon: Icons.chat_bubble_rounded,
        iconColor: const Color(0xFF0891B2),
      ),
    ];'''

    new_class = '''class _NotificationsScreen extends StatefulWidget {
  const _NotificationsScreen();

  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen> {
  final NotificationApi _api = NotificationApi();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndMarkRead();
  }

  Future<void> _fetchAndMarkRead() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
    if (mobile != null && mobile.isNotEmpty) {
      final notifs = await _api.fetchNotifications(mobileNumber: mobile);
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
      // Silently mark as read
      await _api.markAsRead(mobileNumber: mobile);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return 'just now';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return 'just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '\d ago';
    if (diff.inHours > 0) return '\h ago';
    if (diff.inMinutes > 0) return '\m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {'''

    if old_class in content:
        print('Found old class exact match')
    else:
        # Fallback to regex or simpler replace
        content = content.split('class _NotificationsScreen extends StatelessWidget {')[0] + new_class + content.split('    ];')[1]

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify('app/lib/features/home/presentation/home_screen.dart')