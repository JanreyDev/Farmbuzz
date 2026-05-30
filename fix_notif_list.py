import sys

def modify(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    old_listview = '''            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final n = items[index];'''
    
    new_listview = '''            Expanded(
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
                            final title = actor + ' ' + msg;
                            
                            final n = _NotifItem(
                              title: title,
                              subtitle: '',
                              time: _formatTime(raw['created_at'] as String?),
                              unread: raw['read_at'] == null,
                              typeIcon: typeIcon,
                              iconColor: iconColor,
                            );'''
    
    if old_listview in content:
        content = content.replace(old_listview, new_listview)
        print("Success")
    else:
        print("Failed to find exact match")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify('app/lib/features/home/presentation/home_screen.dart')