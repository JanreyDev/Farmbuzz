import 'package:app/app/navigation/app_routes.dart';
import 'package:app/features/onboarding/presentation/widgets/custom_button.dart';
import 'package:app/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:app/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:flutter/material.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const _items = <_OnboardingItem>[
    _OnboardingItem(
      title: 'Manage Your Farm',
      description:
          'Track your flock, records, and farm activities in one organized place.',
      icon: Icons.agriculture_rounded,
      badge: 'Smart Farm Tools',
      highlights: ['Daily records in one tap', 'Health and growth tracking'],
    ),
    _OnboardingItem(
      title: 'Join the Community',
      description:
          'Connect with fellow farmers, share updates, and learn from trusted groups.',
      icon: Icons.groups_rounded,
      badge: 'Farmer Network',
      highlights: ['Join local groups fast', 'Exchange tips and updates'],
    ),
    _OnboardingItem(
      title: 'Shop What You Need',
      description:
          'Discover supplies, tools, and essentials tailored for your farm goals.',
      icon: Icons.shopping_bag_rounded,
      badge: 'Farm Marketplace',
      highlights: ['Browse trusted listings', 'Buy essentials quickly'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTrial() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.subscription);
  }

  Future<void> _handleNext() async {
    if (_currentIndex == _items.length - 1) {
      _goToTrial();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      body: Stack(
        children: [
          const _BackdropAccent(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _goToTrial,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(64, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: _kDarkGreen,
                        ),
                        child: Text(
                          'Skip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _kDarkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return OnboardingPage(
                          title: item.title,
                          description: item.description,
                          icon: item.icon,
                          badge: item.badge,
                          highlights: item.highlights,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          _kLightGreen.withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD9E6DB)),
                      boxShadow: [
                        BoxShadow(
                          color: _kDarkGreen.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PageIndicator(
                          currentIndex: _currentIndex,
                          totalPages: _items.length,
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          label: isLastPage ? 'Continue' : 'Next',
                          onPressed: _handleNext,
                        ),
                      ],
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

class _BackdropAccent extends StatelessWidget {
  const _BackdropAccent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          left: -120,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kLightGreen.withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -90,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kPrimaryGreen.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
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
}
