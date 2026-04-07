import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.validator,
    this.textInputAction,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9B9B9B)),
            filled: true,
            fillColor: const Color(0xFFE9EBEF),
            prefixIcon: Icon(
              prefixIcon,
              size: 19,
              color: const Color(0xFF9B9B9B),
            ),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    onPressed: onSuffixTap,
                    icon: Icon(
                      suffixIcon,
                      size: 19,
                      color: const Color(0xFF9B9B9B),
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
