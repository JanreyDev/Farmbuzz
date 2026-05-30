import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/message_api.dart';
import 'conversation_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final MessageApi _api = MessageApi();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _suggested = [];
  bool _isLoading = false;
  bool _isLoadingSuggested = true;
  Timer? _debounce;
  String? _mobile;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _mobile =
        prefs.getString('auth_mobile_number') ??
        prefs.getString('mobile_number');
    if (_mobile != null && _mobile!.isNotEmpty) {
      _loadSuggested();
    } else {
      setState(() => _isLoadingSuggested = false);
    }
  }

  Future<void> _loadSuggested() async {
    try {
      final list = await _api.fetchSuggestedUsers(_mobile!);
      if (mounted) {
        setState(() {
          _suggested = list
              .where((u) => u['mobile_number'] != _mobile)
              .toList();
          _isLoadingSuggested = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSuggested = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isLoading = true);
      try {
        final res = await _api.searchUsers(query.trim());
        if (mounted) {
          setState(() {
            _results = res.where((u) => u['mobile_number'] != _mobile).toList();
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    if (_mobile == null) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF16A34A)),
        ),
      );
      final conversationId = await _api.startConversation(
        mobileNumber: _mobile!,
        targetName: user['name'],
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      final conversation = ConversationModel(
        id: conversationId,
        otherUserName: user['name'],
        otherUserAvatar: user['avatar_url'] ?? '',
        lastMessage: '',
        lastMessageTime: '',
        isUnread: false,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(conversation: conversation),
        ),
      );
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to start chat')));
      }
    }
  }

  Widget _buildUserTile(Map<String, dynamic> u) {
    final name = (u['name'] as String?) ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatar = u['avatar_url'] as String?;
    return InkWell(
      onTap: () => _startChat(u),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: (avatar != null && avatar.isNotEmpty)
                  ? NetworkImage(avatar)
                  : null,
              child: (avatar == null || avatar.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to start chatting',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          autofocus: true,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          cursorColor: const Color(0xFF16A34A),
          decoration: const InputDecoration(
            hintText: 'Search for someone...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF3F4F6), height: 1),
        ),
      ),
      body: isSearching
          ? _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                  )
                : _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Color(0xFFD1D5DB),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No users found for '${_controller.text}'",
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 70,
                    ),
                    itemBuilder: (context, index) =>
                        _buildUserTile(_results[index]),
                  )
          : _isLoadingSuggested
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            )
          : _suggested.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Color(0xFFD1D5DB),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search for a user above\nto start a conversation',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Suggested Contacts',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _suggested.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 70,
                    ),
                    itemBuilder: (context, index) =>
                        _buildUserTile(_suggested[index]),
                  ),
                ),
              ],
            ),
    );
  }
}
