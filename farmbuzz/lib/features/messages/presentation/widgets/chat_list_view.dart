import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'chat_mock_data.dart';
import 'category_chip.dart';
import 'chat_list_item.dart';

class ChatListView extends StatefulWidget {
  final String? selectedChatId;
  final Function(String) onChatSelected;

  const ChatListView({
    super.key,
    this.selectedChatId,
    required this.onChatSelected,
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  String selectedFilter = 'All';

  List<ChatPreview> get filteredChats {
    if (selectedFilter == 'All') return mockChats;
    if (selectedFilter == 'Unread') return mockChats.where((c) => c.isUnread).toList();
    if (selectedFilter == 'Direct') return mockChats.where((c) => c.type == 'Direct').toList();
    if (selectedFilter == 'Clubs') return mockChats.where((c) => c.type == 'Club').toList();
    return mockChats;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search chats and messages...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              // Pill shape
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              // Green outline when focused
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        // Categories (Full Width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: CategoryChip(
                  label: 'All',
                  isActive: selectedFilter == 'All',
                  onTap: () => setState(() => selectedFilter = 'All'),
                ),
              ),
              Expanded(
                child: CategoryChip(
                  label: 'Unread',
                  isActive: selectedFilter == 'Unread',
                  onTap: () => setState(() => selectedFilter = 'Unread'),
                ),
              ),
              Expanded(
                child: CategoryChip(
                  label: 'Direct',
                  isActive: selectedFilter == 'Direct',
                  onTap: () => setState(() => selectedFilter = 'Direct'),
                ),
              ),
              Expanded(
                child: CategoryChip(
                  label: 'Clubs',
                  isActive: selectedFilter == 'Clubs',
                  onTap: () => setState(() => selectedFilter = 'Clubs'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Chat List
        Expanded(
          child: ListView.separated(
            itemCount: filteredChats.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 80,
              color: AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ChatListItem(
                chat: chat,
                isSelected: widget.selectedChatId == chat.id,
                onTap: () => widget.onChatSelected(chat.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
