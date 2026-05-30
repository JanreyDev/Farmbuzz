import sys

def modify(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Convert to StatefulWidget and add state properties/methods
    old_class = "class _NotificationsScreen extends StatelessWidget {\n  const _NotificationsScreen();"
    new_class = """class _NotificationsScreen extends StatefulWidget {
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
    if (diff.inDays > 0) return diff.inDays.toString() + 'd ago';
    if (diff.inHours > 0) return diff.inHours.toString() + 'h ago';
    if (diff.inMinutes > 0) return diff.inMinutes.toString() + 'm ago';
    return 'just now';
  }"""
    
    content = content.replace(old_class, new_class)

    # 2. Remove the mock items list
    old_items_start = "final items = <_NotifItem>["
    old_items_end = "];"
    
    start_idx = content.find(old_items_start)
    end_idx = content.find(old_items_end, start_idx) + len(old_items_end)
    content = content[:start_idx] + content[end_idx:]

    # 3. Replace ListView.separated
    old_listview = """            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final n = items[index];"""
    
    new_listview = """            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
                  : _notifications.isEmpty
                      ? const Center(child: Text('No notifications yet', style: TextStyle(color: Colors.black54)))
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 8, bottom: 10),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final raw = _notifications[index];
                            final data = raw['data'] as Map<String, dynamic>? ?? {};
                            final type = raw['type'] as String? ?? '';
                            
                            IconData typeIcon = Icons.notifications_rounded;
                            Color iconColor = const Color(0xFF6B7280);
                            
                            if (type == 'like') {
                              typeIcon = Icons.thumb_up_alt_rounded;
                              iconColor = const Color(0xFF16A34A);
                            } else if (type == 'follow') {
                              typeIcon = Icons.person_add_rounded;
                              iconColor = const Color(0xFF2563EB);
                            } else if (type == 'message') {
                              typeIcon = Icons.chat_bubble_rounded;
                              iconColor = const Color(0xFF0891B2);
                            }

                            final actor = data['actor_name']?.toString() ?? 'Someone';
                            final msg = data['message']?.toString() ?? 'interacted with you';
                            
                            final n = _NotifItem(
                              title: actor + ' ' + msg,
                              subtitle: '',
                              time: _formatTime(raw['created_at'] as String?),
                              unread: raw['read_at'] == null,
                              typeIcon: typeIcon,
                              iconColor: iconColor,
                            );"""
    
    content = content.replace(old_listview, new_listview)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify('app/lib/features/home/presentation/home_screen.dart')