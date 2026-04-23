import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF041C06),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
            ),
            accountName: const Text(
              'Janrey',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('janrey@farmbuzz.ph'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).pop(); // Go back to landing (simple logout)
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
