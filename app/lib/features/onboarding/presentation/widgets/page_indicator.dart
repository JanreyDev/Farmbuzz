import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  final int currentIndex;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 26 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? _kPrimaryGreen
                : (isDark
                    ? const Color(0xFF8DA998).withValues(alpha: 0.35)
                    : _kDarkGreen.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
