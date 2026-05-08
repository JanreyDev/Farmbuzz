import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'country_picker.dart';

class MobileInput extends StatefulWidget {
  const MobileInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<MobileInput> createState() => _MobileInputState();
}

class _MobileInputState extends State<MobileInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? AppColors.accentGreen.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.1),
          width: _isFocused ? 1.4 : 1.0,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        children: [
          const CountryPicker(isCompact: false),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: Colors.white10),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.number,
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
        ],
      ),
    );
  }
}
