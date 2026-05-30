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
  bool _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
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
          decoration: const InputDecoration(
            hintText: 'Search for someone...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            )
          : _results.isEmpty && _controller.text.trim().isNotEmpty
          ? const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = _results[index];
                final initial = (u['name'] as String).isNotEmpty
                    ? (u['name'] as String)[0].toUpperCase()
                    : 'U';
                final avatar = u['avatar_url'] as String?;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: (avatar != null && avatar.isNotEmpty)
                        ? NetworkImage(avatar)
                        : null,
                    child: (avatar == null || avatar.isEmpty)
                        ? Text(
                            initial,
                            style: const TextStyle(color: Color(0xFF374151)),
                          )
                        : null,
                  ),
                  title: Text(
                    u['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _startChat(u),
                );
              },
            ),
    );
  }
}
