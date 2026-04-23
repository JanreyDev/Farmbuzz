import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

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
    return Container(
      decoration: isEnabled
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isEnabled ? AppColors.accentGreen : const Color(0xFF2D2D2D),
          foregroundColor: isEnabled ? Colors.black : Colors.white.withValues(alpha: 0.3),
          disabledBackgroundColor: const Color(0xFF1A1A1A),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.1),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
