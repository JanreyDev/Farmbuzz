import 'package:flutter/material.dart';

enum ActivityType { farm, posts, social }

class ActivityItem {
  final String title;
  final String description;
  final int xp;
  final ActivityType type;
  final DateTime timestamp;
  final IconData icon;
  final Color iconBgColor;

  ActivityItem({
    required this.title,
    required this.description,
    required this.xp,
    required this.type,
    required this.timestamp,
    required this.icon,
    required this.iconBgColor,
  });
}
