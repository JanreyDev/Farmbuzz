import 'package:flutter/material.dart';

class CountryPicker extends StatelessWidget {
  const CountryPicker({super.key, required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: 20,
            height: 14,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: Container(color: const Color(0xFF0038A8))),
                    Expanded(child: Container(color: const Color(0xFFCE1126))),
                  ],
                ),
                Container(
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '+63',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
