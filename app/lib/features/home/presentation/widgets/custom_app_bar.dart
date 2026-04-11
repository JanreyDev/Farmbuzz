import 'package:app/app/navigation/app_routes.dart';
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
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16, right: 6),
        child: Row(
          children: [
            SizedBox(
              width: 132,
              height: 34,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/Logowhite.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            _HeaderActionIcon(
              icon: Icons.notifications_outlined,
              tooltip: 'Notifications',
              onPressed: () {},
            ),
            _HeaderActionIcon(
              icon: Icons.chat_bubble_outline,
              tooltip: 'Messages',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.messaging),
            ),
            Builder(
              builder: (context) => _HeaderActionIcon(
                icon: Icons.menu_rounded,
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        iconSize: 22,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
