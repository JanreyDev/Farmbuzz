import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isActive = index < count;
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            color: isActive ? Colors.white : Colors.transparent,
          ),
        );
      }),
    );
  }
}
