import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isEnabled
              ? const [Color(0xFF16A34A), Color(0xFF1ED760)]
              : const [Color(0xFF2A322F), Color(0xFF3A423E)],
        ),
        boxShadow: [
          if (isEnabled)
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.40),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: borderRadius,
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isEnabled
                      ? const Color(0xFF04210E)
                      : Colors.white.withValues(alpha: 0.28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
