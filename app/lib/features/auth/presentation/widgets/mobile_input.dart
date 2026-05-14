import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'country_picker.dart';

class MobileInput extends StatefulWidget {
  const MobileInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isValid,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isValid;

  @override
  State<MobileInput> createState() => _MobileInputState();
}

class _MobileInputState extends State<MobileInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? AppColors.accentGreen.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.1),
          width: isFocused ? 1.4 : 1.0,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        children: [
          const CountryPicker(),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: Colors.white10),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '9XX XXXX XXX',
                hintStyle: TextStyle(color: AppColors.hintGrey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: widget.isValid ? 1 : 0,
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: Color(0xFF2CD56E),
            ),
          ),
          if (widget.isValid) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
