import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class CheckboxTile extends StatelessWidget {
  const CheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? AppColors.accentGreen : Colors.white24,
                width: 1.5,
              ),
              color: value ? AppColors.accentGreen.withValues(alpha: 0.1) : Colors.transparent,
              boxShadow: [
                if (value)
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: AppColors.accentGreen)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: label),
        ],
      ),
    );
  }
}
