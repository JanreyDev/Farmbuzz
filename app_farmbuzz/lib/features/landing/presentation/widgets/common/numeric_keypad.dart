import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onTap,
    required this.onDelete,
  });

  final ValueChanged<String> onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9']
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (var key in row) ...[
                  Expanded(child: KeyButton(label: key, onTap: () => onTap(key))),
                  if (key != row.last) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        Row(
          children: [
            const Expanded(child: SizedBox()), // Placeholder for empty space
            const SizedBox(width: 12),
            Expanded(child: KeyButton(label: '0', onTap: () => onTap('0'))),
            const SizedBox(width: 12),
            Expanded(
              child: KeyButton(
                icon: Icons.backspace_outlined,
                onTap: onDelete,
                isSpecial: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.isSpecial = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSpecial;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isSpecial ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: isSpecial ? Colors.white70 : Colors.black54, size: 20)
            : Text(
                label!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
