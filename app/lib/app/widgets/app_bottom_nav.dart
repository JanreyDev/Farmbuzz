import 'package:flutter/material.dart';

enum AppBottomNavItem { home, explore, market, create, profile }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.12)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _indexForItem(activeItem),
        onTap: (index) => onItemTap(_itemForIndex(index)),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: theme.cardColor,
        selectedItemColor: selectedColor,
        unselectedItemColor: inactiveColor,
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
