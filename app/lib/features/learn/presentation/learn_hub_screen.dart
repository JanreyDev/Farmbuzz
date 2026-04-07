import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const Color _kLearnBackground = Color(0xFFF0F2F5);
const Color _kLearnMutedText = Color(0xFF7C828C);

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topics = [
      _TopicData(
        title: 'Bloodline Encyclopedia',
        subtitle: '18 bloodline profiles with traits, history, and cross recommendations',
        articleCount: 18,
        icon: Icons.hub_outlined,
        iconColor: Color(0xFFC49A27),
        iconBackground: Color(0xFFFBF4E3),
      ),
      _TopicData(
        title: 'Conditioning Guides',
        subtitle: 'Step-by-step 14/21/28-day programs from champion breeders',
        articleCount: 6,
        icon: Icons.monitor_heart_outlined,
        iconColor: Color(0xFFE26D2E),
        iconBackground: Color(0xFFFFF0E7),
      ),
      _TopicData(
        title: 'Disease Library',
        subtitle: 'Common diseases: symptoms, prevention, treatment with photos',
        articleCount: 24,
        icon: Icons.coronavirus_outlined,
        iconColor: Color(0xFFC44A4A),
        iconBackground: Color(0xFFFFECEC),
      ),
      _TopicData(
        title: 'Breeding 101',
        subtitle: 'Inbreeding vs outcrossing, selection, progeny testing',
        articleCount: 8,
        icon: Icons.favorite_border,
        iconColor: Color(0xFFC64C78),
        iconBackground: Color(0xFFFFEFF6),
      ),
      _TopicData(
        title: 'Feeding Guides',
        subtitle: 'Nutrition by phase: maintenance, pre-conditioning, pointing',
        articleCount: 5,
        icon: Icons.eco_outlined,
        iconColor: Color(0xFF3E9B5F),
        iconBackground: Color(0xFFEAF7EE),
      ),
      _TopicData(
        title: 'Farm Setup',
        subtitle: 'Pen design, sanitation flow, staffing, and daily checklists',
        articleCount: 7,
        icon: Icons.home_work_outlined,
        iconColor: Color(0xFF4A72C4),
        iconBackground: Color(0xFFEEF4FF),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF1F2230),
                          tooltip: 'Back',
                        ),
                        const Expanded(
                          child: Text(
                            'Learn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2230),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                          color: const Color(0xFF5E6570),
                          tooltip: 'Search',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: _kLearnBackground,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                        children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Master gamefowl breeding with guides from champion breeders. All content in Taglish.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _kLearnMutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kGoldAccent, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBF4E3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              color: kGoldAccent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Beginner's Guide to Sabong Breeding",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2230),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Everything you need to know to start your first gamefarm. From choosing bloodlines to your first derby.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: _kLearnMutedText,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Start Reading',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kGoldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Topics',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...topics.map(
                      (topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TopicCard(topic: topic),
                      ),
                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNav(
              activeItem: AppBottomNavItem.explore,
              onItemTap: (item) {
                if (item == AppBottomNavItem.home) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.newsFeed);
                } else if (item == AppBottomNavItem.explore) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.explore);
                } else if (item == AppBottomNavItem.create ||
                    item == AppBottomNavItem.market) {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.marketplace,
                  );
                } else if (item == AppBottomNavItem.profile) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final _TopicData topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: topic.iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(topic.icon, size: 20, color: topic.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  topic.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kLearnMutedText,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                topic.articleCount.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2230),
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'articles',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _kLearnMutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicData {
  const _TopicData({
    required this.title,
    required this.subtitle,
    required this.articleCount,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String title;
  final String subtitle;
  final int articleCount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}
