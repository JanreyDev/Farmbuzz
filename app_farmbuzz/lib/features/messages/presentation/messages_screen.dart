import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'widgets/chat_list_view.dart';
import 'widgets/chat_detail_view.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/features/messages/data/message_api.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    this.initialChatId,
  });

  final String? initialChatId;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageApi _messageApi = MessageApi();
  String? selectedChatId;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialChatId != null) {
      _initConversation(widget.initialChatId!);
    }
  }

  Future<void> _initConversation(String targetName) async {
    final mobile = AppSession.mobileNumber;
    if (mobile == null || mobile.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to send messages.')),
        );
      }
      return;
    }

    setState(() => _isInitializing = true);
    try {
      final id = await _messageApi.startConversation(
        mobileNumber: mobile,
        targetName: targetName,
      );
      if (mounted) {
        setState(() {
          selectedChatId = id.toString();
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start conversation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isMobile && selectedChatId != null
          ? null // Detail view will have its own AppBar
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0.5,
              title: const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_note, color: AppColors.accentGreen),
                  onPressed: () {},
                ),
              ],
            ),
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : (isMobile
                ? (selectedChatId == null
                    ? ChatListView(
                        onChatSelected: (id) => setState(() => selectedChatId = id),
                      )
                    : ChatDetailView(
                        chatId: selectedChatId!,
                        onBack: () => setState(() => selectedChatId = null),
                      ))
                : Row(
                    children: [
                      SizedBox(
                        width: 350,
                        child: ChatListView(
                          selectedChatId: selectedChatId,
                          onChatSelected: (id) => setState(() => selectedChatId = id),
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),
                      Expanded(
                        child: selectedChatId == null
                            ? const Center(
                                child: Text(
                                  'Select a chat to start messaging',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ChatDetailView(chatId: selectedChatId!),
                      ),
                    ],
                  )),
      ),
    );
  }
}
