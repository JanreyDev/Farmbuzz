import 'package:flutter/material.dart';

const Color _kChatBg = Color(0xFFF5F5F5);
const Color _kChatSurface = Color(0xFFF5F5F5);
const Color _kOutgoingBubble = Color(0xFF2E7D32);
const Color _kIncomingBubble = Colors.white;
const Color _kSoftGreen = Color(0xFFE8F5E9);
const Color _kMutedText = Color(0xFF7A8680);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkText = Color(0xFF1F2A22);

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kChatBg,
      body: Column(
        children: const [
          _ChatHeader(),
          Expanded(child: _ChatBody()),
          _Composer(),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(8, topInset, 8, 0),
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, size: 20, color: _kDarkText),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _kSoftGreen,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'MD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kPrimaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mario Dela Cruz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kDarkText,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: _kPrimaryGreen),
                    SizedBox(width: 3),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 10, color: _kPrimaryGreen),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.call_outlined,
                size: 18,
                color: _kPrimaryGreen,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: Color(0xFF7D838C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    const messages = [
      _Message(text: 'Bro available pa ba yung Kelso stags?', time: '10:30 AM'),
      _Message(
        text: 'Oo pare, may 3 pa available. 7 months old na',
        time: '10:32 AM',
        isMine: true,
      ),
      _Message(text: 'Galing saan yung bloodline? Pure ba?', time: '10:33 AM'),
      _Message(
        text: 'Pure Kelso from our champion line. Father is Thunder - 8W 1L record',
        time: '10:35 AM',
        isMine: true,
      ),
      _Message(text: 'Solid! Magkano per head?', time: '10:36 AM'),
      _Message(
        text: '\u20B18,500 each. Bulk discount if you take all 3 - \u20B122,000',
        time: '10:38 AM',
        isMine: true,
      ),
      _Message(
        text: 'Can I visit your farm this weekend to see them in person?',
        time: '10:40 AM',
      ),
      _Message(
        text: 'Sure! Saturday morning works. I\'ll send you the pin location',
        time: '10:41 AM',
        isMine: true,
      ),
    ];

    return Container(
      color: _kChatSurface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        itemCount: messages.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _MessageBubble(message: messages[index]),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isMine ? _kOutgoingBubble : _kIncomingBubble;
    final textColor = message.isMine ? Colors.white : _kDarkText;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(message.isMine ? 12 : 4),
      bottomRight: Radius.circular(message.isMine ? 4 : 12),
    );

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Column(
          crossAxisAlignment:
              message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: radius,
                border: message.isMine
                    ? null
                    : Border.all(color: const Color(0xFFE2E6EB)),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.time,
              style: const TextStyle(fontSize: 9, color: _kMutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add, color: _kPrimaryGreen, size: 20),
            ),
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _kPrimaryGreen.withValues(alpha: 0.35),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Type a message...',
                  style: TextStyle(fontSize: 12, color: _kMutedText),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: _kMutedText,
                size: 19,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _kPrimaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, size: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  const _Message({
    required this.text,
    required this.time,
    this.isMine = false,
  });

  final String text;
  final String time;
  final bool isMine;
}
