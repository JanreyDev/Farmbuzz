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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var key in row)
                  KeyButton(label: key, onTap: () => onTap(key)),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 100), // Space for alignment
            KeyButton(label: '0', onTap: () => onTap('0')),
            KeyButton(
              icon: Icons.backspace_outlined,
              onTap: onDelete,
              isSpecial: true,
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
        width: 100,
        height: 54,
        decoration: BoxDecoration(
          color: isSpecial ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: Colors.black54, size: 20)
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
