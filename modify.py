import sys

def modify_home_screen(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add import
    content = content.replace("import '../data/story_api.dart';", "import '../data/story_api.dart';\nimport '../data/notification_api.dart';")

    # 2. Update _HomeScreenState variables and initState
    old_state = '''  bool _hasFarm = false;
  bool _isFarmLoading = true;
  bool _isChecking = false;
  final FarmApi _farmApi = FarmApi();

  @override
  void initState() {
    super.initState();
    _ViewerProfileStore.instance.load();
    _checkFarmStatus();
  }'''
    
    new_state = '''  bool _hasFarm = false;
  bool _isFarmLoading = true;
  bool _isChecking = false;
  final FarmApi _farmApi = FarmApi();
  final NotificationApi _notifApi = NotificationApi();
  int _unreadMessages = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _ViewerProfileStore.instance.load();
    _checkFarmStatus();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
    if (mobile != null && mobile.isNotEmpty) {
      final counts = await _notifApi.fetchCounts(mobileNumber: mobile);
      if (mounted) {
        setState(() {
          _unreadMessages = counts['messages'] ?? 0;
          _unreadNotifications = counts['notifications'] ?? 0;
        });
      }
    }
  }'''
    if old_state in content:
        content = content.replace(old_state, new_state)
    else:
        print("old_state not found!")

    # 3. Update _HomeHeader definition
    old_header = '''class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const int _unreadMessages = 3;
  static const int _unreadNotifications = 7;'''
    
    new_header = '''class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    super.key,
    required this.unreadMessages,
    required this.unreadNotifications,
  });

  final int unreadMessages;
  final int unreadNotifications;'''
    content = content.replace(old_header, new_header)

    # 4. Replace count references inside _HomeHeader
    content = content.replace("count: _unreadMessages,", "count: unreadMessages,")
    content = content.replace("count: _unreadNotifications,", "count: unreadNotifications,")

    # 5. Replace const _HomeHeader() usage in _HomeScreenState
    content = content.replace("const _HomeHeader()", "_HomeHeader(unreadMessages: _unreadMessages, unreadNotifications: _unreadNotifications)")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

modify_home_screen('app/lib/features/home/presentation/home_screen.dart')