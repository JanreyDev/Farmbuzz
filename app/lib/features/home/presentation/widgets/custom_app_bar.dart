import 'package:flutter/material.dart';

const Color _kHomeBg = Color(0xFF2E7D32);

class FarmBuzzHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FarmBuzzHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _kHomeBg,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 42,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        padding: const EdgeInsets.only(left: 10, right: 4),
        visualDensity: VisualDensity.compact,
        tooltip: 'Menu',
      ),
      centerTitle: false,
      titleSpacing: 4,
      title: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
        ),
        child: SizedBox(
          height: 22,
          child: Image.asset(
            'assets/images/Logo.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
      actions: [
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          tooltip: 'Messages',
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Colors.white),
          tooltip: 'Search',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
