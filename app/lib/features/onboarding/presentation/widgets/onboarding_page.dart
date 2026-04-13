import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
    required this.highlights,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badge;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardTop = isDark ? const Color(0xFF1B2420) : const Color(0xFFFFFFFF);
    final cardBottom = isDark ? const Color(0xFF141D18) : const Color(0xFFF4FAF5);
    final cardBorder = isDark ? const Color(0xFF33453A) : const Color(0xFFD8E7DA);
    final innerCardBg = isDark ? const Color(0xFF18231D) : const Color(0xFFEEF6EF);
    final innerCardBorder = isDark ? const Color(0xFF33473C) : const Color(0xFFD8E8DA);
    final titleColor = isDark ? const Color(0xFFE6F5E8) : const Color(0xFF152217);
    final descColor = isDark ? const Color(0xFFA9BAAE) : const Color(0xFF4C5E50);
    final highlightColor = isDark ? const Color(0xFFC7D8CC) : const Color(0xFF273328);
    final badgeColor = isDark ? const Color(0xFFE2F2E4) : _kDarkGreen;
    final dotsColor = isDark
        ? const Color(0xFFBFD5C6).withValues(alpha: 0.55)
        : _kDarkGreen.withValues(alpha: 0.42);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [cardTop, cardBottom],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: _kDarkGreen.withValues(alpha: isDark ? 0.24 : 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kPrimaryGreen.withValues(alpha: 0.22),
                              _kLightGreen.withValues(alpha: 0.20),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: dotsColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: innerCardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: innerCardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [_kDarkGreen, _kPrimaryGreen],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kPrimaryGreen.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(icon, size: 30, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_kDarkGreen, _kPrimaryGreen],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _kDarkGreen.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 140,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _kDarkGreen.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...highlights.take(2).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _kPrimaryGreen,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                      color: highlightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              height: 1.35,
              color: descColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
