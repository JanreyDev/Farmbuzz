import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'common/pin_dots.dart';
import 'common/numeric_keypad.dart';

class PinLoginCard extends StatefulWidget {
  const PinLoginCard({
    super.key,
    required this.isCompact,
    required this.phoneNumber,
    required this.onNotYou,
    required this.onForgotPin,
  });

  final bool isCompact;
  final String phoneNumber;
  final VoidCallback onNotYou;
  final VoidCallback onForgotPin;

  @override
  State<PinLoginCard> createState() => _PinLoginCardState();
}

class _PinLoginCardState extends State<PinLoginCard> {
  String _pin = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        widget.isCompact ? 16 : 24,
        widget.isCompact ? 20 : 28,
        widget.isCompact ? 16 : 24,
        widget.isCompact ? 24 : 32,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardDarkGreen.withValues(alpha: 0.9),
            AppColors.cardDeepGreen.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSerif(
              fontSize: widget.isCompact ? 24 : 26,
              color: const Color(0xFFEAF7ED),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.phoneNumber,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onNotYou,
            child: const Text(
              'Not you?',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          PinDots(count: _pin.length),
          const SizedBox(height: 32),
          NumericKeypad(
            onTap: (val) {
              if (_pin.length < 6) {
                setState(() => _pin += val);
                if (_pin.length == 6) {
                  // Submit logic
                }
              }
            },
            onDelete: () {
              if (_pin.isNotEmpty) {
                setState(() => _pin = _pin.substring(0, _pin.length - 1));
              }
            },
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onForgotPin,
            child: const Text(
              'Forgot PIN?',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
