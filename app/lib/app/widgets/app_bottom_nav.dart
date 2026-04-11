import 'package:flutter/material.dart';

enum AppBottomNavItem { home, explore, market, create, profile }

const Color _kNavBg = Color(0xFFFFFFFF);
const Color _kNavBorder = Color(0xFFE2E2E2);
const Color _kNavActive = Color(0xFF2E7D32);
const Color _kNavInactive = Color(0xFF6D6D6D);

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
      decoration: const BoxDecoration(
        color: _kNavBg,
        border: Border(
          top: BorderSide(color: _kNavBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _indexForItem(activeItem),
          onTap: (index) => onItemTap(_itemForIndex(index)),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: _kNavBg,
          selectedItemColor: _kNavActive,
          unselectedItemColor: _kNavInactive,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_outlined),
              activeIcon: Icon(Icons.agriculture),
              label: 'Farm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  int _indexForItem(AppBottomNavItem item) {
    switch (item) {
      case AppBottomNavItem.home:
        return 0;
      case AppBottomNavItem.explore:
        return 1;
      case AppBottomNavItem.market:
        return 2;
      case AppBottomNavItem.create:
        return 3;
      case AppBottomNavItem.profile:
        return 4;
    }
  }

  AppBottomNavItem _itemForIndex(int index) {
    switch (index) {
      case 0:
        return AppBottomNavItem.home;
      case 1:
        return AppBottomNavItem.explore;
      case 2:
        return AppBottomNavItem.market;
      case 3:
        return AppBottomNavItem.create;
      case 4:
      default:
        return AppBottomNavItem.profile;
    }
  }
}
