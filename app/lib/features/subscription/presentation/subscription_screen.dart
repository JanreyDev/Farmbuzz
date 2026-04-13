import 'package:app/app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kPageBg = Color(0xFFF6F4EE);

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF101512) : _kPageBg;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(theme: theme, isDark: isDark),
                    const SizedBox(height: 14),
                    _HeroCard(isDark: isDark),
                    const SizedBox(height: 14),
                    _TimelineCard(isDark: isDark),
                    const SizedBox(height: 14),
                    _IncludedCard(isDark: isDark),
                    const SizedBox(height: 14),
                    _PlanCard(isDark: isDark),
                  ],
                ),
              ),
            ),
            _BottomCta(
              isDark: isDark,
              onStart: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.isDark});

  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: _kDarkGreen,
          tooltip: 'Back',
        ),
        Expanded(
          child: Text(
            'Start Your Trial',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFE3F3E5) : _kDarkGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.help_outline),
          color: isDark
              ? const Color(0xFFBBD1C1).withValues(alpha: 0.8)
              : _kDarkGreen.withValues(alpha: 0.75),
          tooltip: 'Help',
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1A231E), Color(0xFF16201B)]
              : const [Color(0xFFF0F7F1), Color(0xFFE2F0E4)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? const Color(0xFF34463B) : const Color(0xFFCEE1D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_available, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '30-Day Free Trial',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? const Color(0xFFE3F3E5) : _kDarkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Enjoy full FarmBuzz access today with zero upfront payment.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? const Color(0xFFAABBB0) : const Color(0xFF3F5242),
              height: 1.32,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.lock_clock_outlined,
                label: 'No charge today',
                isDark: isDark,
              ),
              _MiniPill(
                icon: Icons.cancel_outlined,
                label: 'Cancel anytime',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.icon, required this.label, required this.isDark});

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2721) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? const Color(0xFF3B4D42) : const Color(0xFFD7E5D9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _kPrimaryGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFC2D4C7) : const Color(0xFF345138),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      isDark: isDark,
      title: 'What happens next',
      titleStyle: theme.textTheme.titleMedium?.copyWith(
        color: isDark ? const Color(0xFFE3F3E5) : _kDarkGreen,
        fontWeight: FontWeight.w800,
      ),
      child: Column(
        children: [
          _StepRow(
            step: '1',
            title: 'Start your free trial',
            subtitle: 'Get instant access to all FarmBuzz features.',
            isDark: isDark,
          ),
          _StepRow(
            step: '2',
            title: 'We remind you before billing',
            subtitle: 'We send a reminder before the trial ends.',
            isDark: isDark,
          ),
          _StepRow(
            step: '3',
            title: 'Continue for \u20B139.99/month',
            subtitle: 'Or cancel anytime during trial with no charge.',
            isLast: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.isLast = false,
  });

  final String step;
  final String title;
  final String subtitle;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPrimaryGreen,
                ),
                alignment: Alignment.center,
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 36,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isDark ? const Color(0xFF3A4D41) : const Color(0xFFD5E5D7),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFE0F1E2) : const Color(0xFF1F2A21),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFFA8B9AE) : const Color(0xFF556458),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncludedCard extends StatelessWidget {
  const _IncludedCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      isDark: isDark,
      title: 'Everything included',
      titleStyle: theme.textTheme.titleMedium?.copyWith(
        color: isDark ? const Color(0xFFE3F3E5) : _kDarkGreen,
        fontWeight: FontWeight.w800,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FeaturePill(label: 'Farm Records', isDark: isDark),
          _FeaturePill(label: 'Community Groups', isDark: isDark),
          _FeaturePill(label: 'Marketplace Access', isDark: isDark),
          _FeaturePill(label: 'Insights & Reports', isDark: isDark),
          _FeaturePill(label: 'Messaging', isDark: isDark),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A251F) : const Color(0xFFF0F7F1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? const Color(0xFF395044) : const Color(0xFFD3E5D6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 15, color: _kPrimaryGreen),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFC2D4C7) : const Color(0xFF2C4330),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      isDark: isDark,
      title: 'FarmBuzz Plan',
      titleStyle: theme.textTheme.titleMedium?.copyWith(
        color: isDark ? const Color(0xFFE3F3E5) : _kDarkGreen,
        fontWeight: FontWeight.w800,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\u20B139.99',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: _kPrimaryGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              '/ month',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? const Color(0xFFABBBB0) : const Color(0xFF58655A),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF203026) : const Color(0xFFEAF4EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'After Trial',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFC6E4C9) : const Color(0xFF2B5D30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    required this.titleStyle,
    required this.isDark,
  });

  final String title;
  final Widget child;
  final TextStyle? titleStyle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16201A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF33473B) : const Color(0xFFD9E5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.onStart, required this.isDark});

  final VoidCallback onStart;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16201A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF33473B)
                : const Color(0xFFD8E5DA).withValues(alpha: 0.9),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: _kDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Start 30-Day Free Trial'),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
