import 'package:flutter/material.dart';

enum BirdStatus { active, sick, sold }

class BirdModel {
  const BirdModel({
    required this.name,
    required this.breed,
    required this.age,
    required this.status,
    required this.imageUrl,
  });

  final String name;
  final String breed;
  final String age;
  final BirdStatus status;
  final String imageUrl;

  String get statusLabel {
    switch (status) {
      case BirdStatus.active:
        return 'Active';
      case BirdStatus.sick:
        return 'Sick';
      case BirdStatus.sold:
        return 'Sold';
    }
  }

  Color statusColor(ColorScheme colorScheme) {
    switch (status) {
      case BirdStatus.active:
        return Colors.green.shade700;
      case BirdStatus.sick:
        return colorScheme.error;
      case BirdStatus.sold:
        return colorScheme.onSurface.withValues(alpha: 0.65);
    }
  }
}
