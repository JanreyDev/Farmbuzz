import 'package:flutter/material.dart';

class FarmBuzzHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FarmBuzzHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Menu',
      ),
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'FarmBuzz',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Messages',
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
