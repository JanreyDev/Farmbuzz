import 'package:app/app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

const Color _kDrawerGreen = Color(0xFF2E7D32);
const Color _kDrawerDark = Color(0xFF1B5E20);

class FarmBuzzAppDrawer extends StatelessWidget {
  const FarmBuzzAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

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
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _go(context, AppRoutes.home),
                  ),
                  _DrawerItem(
                    icon: Icons.agriculture_outlined,
                    label: 'Farm',
                    onTap: () => _go(context, AppRoutes.farmDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.storefront_outlined,
                    label: 'Store',
                    onTap: () => _go(context, AppRoutes.marketplace),
                  ),
                  _DrawerItem(
                    icon: Icons.groups_outlined,
                    label: 'Community',
                    onTap: () => _go(context, AppRoutes.groups),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => _go(context, AppRoutes.profile),
                  ),
                  const Divider(height: 20),
                  _DrawerItem(
                    icon: Icons.login,
                    label: 'Login',
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: _kDrawerDark),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF273329),
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
