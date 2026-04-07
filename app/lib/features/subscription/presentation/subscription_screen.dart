import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF242424)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2230),
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _TopIntroBar(),
              Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TrialPlanCard(),
                    SizedBox(height: 16),
                    Text(
                      'After Your Free Trial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    SizedBox(height: 12),
                    _PaidPlanCard(
                      name: 'Manok Plan',
                      amount: '29',
                      period: '/month',
                      features: [
                        'Unlimited posts & stories',
                        'News feed access',
                        'Private messaging',
                        'Marketplace browsing',
                        'Event calendar',
                      ],
                    ),
                    SizedBox(height: 12),
                    _PaidPlanCard(
                      name: 'Panabong Plan',
                      amount: '79',
                      period: '/month',
                      features: [
                        'Everything in Manok Plan',
                        'Bloodline registry tools',
                        'Breeding journal',
                        'Performance tracking',
                        'Priority listing in marketplace',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopIntroBar extends StatelessWidget {
  const _TopIntroBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
      ),
      child: const Text(
        'Start with 2 months free. Experience everything FarmBuzz has to offer.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF6F7378),
          height: 1.35,
        ),
      ),
    );
  }
}

class _TrialPlanCard extends StatelessWidget {
  const _TrialPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGoldAccent, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6EFE0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard, color: kGoldAccent, size: 24),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '60-Day Free Trial',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB38206),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Try everything free for 60 days. No credit card needed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E6E6E),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _PlanFeature(text: 'Full access to ALL features for 60 days'),
          const _PlanFeature(text: 'Unlimited birds, posts & stories'),
          const _PlanFeature(text: 'Bloodline registry & training journal'),
          const _PlanFeature(text: 'Health tracker & conditioning programs'),
          const _PlanFeature(text: 'Marketplace, messaging & groups'),
          const _PlanFeature(text: 'Financial tracker & export reports'),
          const _PlanFeature(text: 'No credit card required'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kGoldAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Start Free Trial'),
          ),
          const SizedBox(height: 6),
          const Text(
            'No payment required. Cancel anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF999999), fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _PaidPlanCard extends StatelessWidget {
  const _PaidPlanCard({
    required this.name,
    required this.amount,
    required this.period,
    required this.features,
  });

  final String name;
  final String amount;
  final String period;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2230),
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '\u20B1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kGoldAccent,
                  ),
                ),
                TextSpan(
                  text: amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2230),
                  ),
                ),
                TextSpan(
                  text: period,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => _PlanFeature(text: feature)),
        ],
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1.5),
            child: Icon(Icons.check, size: 14, color: Color(0xFF5CB85C)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3E3E3E),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
