import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';

const Color _kDrawerGreen = Color(0xFF2E7D32);
const Color _kDrawerDark = Color(0xFF1B5E20);

class FarmBuzzAppDrawer extends StatelessWidget {
  const FarmBuzzAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemTextColor = isDark
        ? const Color(0xFFE8F5E9)
        : const Color(0xFF273329);
    final itemIconColor = isDark ? const Color(0xFFA5D6A7) : _kDrawerDark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.10);

    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kDrawerDark, _kDrawerGreen],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/Logowhite.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeModeController.mode,
                    builder: (context, mode, _) {
                      final isSwitchDark = mode == ThemeMode.system
                          ? Theme.of(context).brightness == Brightness.dark
                          : mode == ThemeMode.dark;
                      return SwitchListTile.adaptive(
                        value: isSwitchDark,
                        onChanged: ThemeModeController.setDarkMode,
                        secondary: Icon(
                          isSwitchDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: itemIconColor,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: itemTextColor,
                          ),
                        ),
                        activeThumbColor: Colors.white,
                        activeTrackColor: _kDrawerGreen,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: isDark
                            ? Colors.white.withValues(alpha: 0.28)
                            : Colors.black.withValues(alpha: 0.18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      );
                    },
                  ),
                  Divider(height: 20, color: dividerColor),
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.home),
                  ),
                  _DrawerItem(
                    icon: Icons.agriculture_outlined,
                    label: 'Farm',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.farmDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.storefront_outlined,
                    label: 'Store',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.marketplace),
                  ),
                  _DrawerItem(
                    icon: Icons.groups_outlined,
                    label: 'Community',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.groups),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.profile),
                  ),
                  Divider(height: 20, color: dividerColor),
                  _DrawerItem(
                    icon: Icons.login,
                    label: 'Login',
                    iconColor: itemIconColor,
                    textColor: itemTextColor,
                    onTap: () => _go(context, AppRoutes.login),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
