import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: const [
            _HomeHeader(),
            _StatusComposer(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/100?img=12';

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(8, topInset + 10, 10, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu is UI-only for now.')),
              );
            },
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 36,
            errorBuilder: (context, error, stackTrace) => const Text(
              'FarmBuzz',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages screen coming next.')),
              );
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications screen coming next.')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage: const NetworkImage(_demoAvatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusComposer extends StatelessWidget {
  const _StatusComposer();

  static const String _demoAvatarUrl = 'https://i.pravatar.cc/100?img=12';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: const NetworkImage(_demoAvatarUrl),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD0D3D6)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's happening on your farm?",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.image, color: AppColors.accentGreen, size: 22),
        ],
      ),
    );
  }
}
