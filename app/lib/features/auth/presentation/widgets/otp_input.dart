import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onChanged,
    required this.isLightMode,
  });

  final ValueChanged<String> onChanged;
  final bool isLightMode;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _controllers.map((controller) => controller.text).join();
    widget.onChanged(otp);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final availableWidth = constraints.maxWidth - (spacing * 5);
        final adaptiveWidth = availableWidth / 6;
        final boxWidth = adaptiveWidth.clamp(36.0, 45.0);

        return Row(
          children: List.generate(6, (index) {
            final isFocused = _focusNodes[index].hasFocus;

            return Padding(
              padding: EdgeInsets.only(right: index == 5 ? 0 : spacing),
              child: Container(
                width: boxWidth,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isLightMode
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.72)
                      : Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.accentGreen
                        : widget.isLightMode
                            ? const Color(0xFFBFC8BE)
                            : Colors.white12,
                    width: isFocused ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (v) {
                    _onChanged(v, index);
                    setState(() {});
                  },
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: widget.isLightMode ? const Color(0xFF314234) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLength: 1,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
