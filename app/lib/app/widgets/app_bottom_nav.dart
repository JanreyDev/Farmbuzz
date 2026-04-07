import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppBottomNavItem { home, explore, create, market, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.activeItem,
    required this.onItemTap,
    super.key,
  });

  final AppBottomNavItem activeItem;
  final ValueChanged<AppBottomNavItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E6EA))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIconButton(
            icon: Icons.home_outlined,
            isActive: activeItem == AppBottomNavItem.home,
            onTap: () => onItemTap(AppBottomNavItem.home),
          ),
          _NavIconButton(
            icon: Icons.explore_outlined,
            isActive: activeItem == AppBottomNavItem.explore,
            onTap: () => onItemTap(AppBottomNavItem.explore),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => onItemTap(AppBottomNavItem.create),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: kGoldAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _NavIconButton(
            icon: Icons.storefront_outlined,
            isActive: activeItem == AppBottomNavItem.market,
            onTap: () => onItemTap(AppBottomNavItem.market),
          ),
          _NavIconButton(
            icon: Icons.person_outline,
            isActive: activeItem == AppBottomNavItem.profile,
            onTap: () => onItemTap(AppBottomNavItem.profile),
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 22,
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? kGoldAccent : const Color(0xFF8A9098),
        size: 22,
      ),
    );
  }
}
