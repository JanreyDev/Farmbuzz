import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/rank_api.dart';
import 'home_screen.dart'; // To access _ViewerProfileStore

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final RankApi _rankApi = RankApi();
  
  bool _isLoading = true;
  String _error = '';
  
  Map<String, dynamic>? _rankData;

  @override
  void initState() {
    super.initState();
    _fetchRank();
  }

  Future<void> _fetchRank() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('auth_mobile_number');
      if (mobile != null) {
        final data = await _rankApi.fetchRank(mobile);
        if (mounted) {
          setState(() {
            _rankData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Not logged in';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _fetchRank, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCCD3DA), Color(0xFFE6EBF0), Color(0xFFF7F9FB)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card 1: Your Rank Card ──
            _buildYourRankCard(),

            const SizedBox(height: 16),

            // ── Card 2: The Four Ranks ──
            _buildFourRanksCard(),

            const SizedBox(height: 16),

            // ── Card 3: How Reputation Grows ──
            _buildReputationGrowsCard(),

            const SizedBox(height: 16),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildYourRankCard() {
    final rankName = _rankData?['current_rank'] ?? 'Bronze';
    final nextRank = _rankData?['next_rank'];
    final progress = _rankData?['progress_percentage'] ?? 0;
    final activity = _rankData?['activity_level'] ?? 'Quiet';
    final memberSince = _rankData?['member_since'] ?? 'May 2026';
    final region = _rankData?['region'] ?? 'the Philippines';

    // Get color based on rank
    Color rankColor = const Color(0xFFC99843); // Bronze
    if (rankName == 'Iron') rankColor = const Color(0xFF9CA3AF);
    if (rankName == 'Silver') rankColor = const Color(0xFFD1D5DB);
    if (rankName == 'Gold') rankColor = const Color(0xFFFBBF24);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent bar
            Container(height: 4, color: rankColor),

            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular avatar "BF"
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF158D42),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'BF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User rank details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pill label "YOUR RANK"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF8F4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: rankColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 10,
                                    color: rankColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'YOUR RANK',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: rankColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$rankName Rank',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              nextRank != null ? '${_rankData?['xp']} XP' : 'Max Rank Reached',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress label
                  Text(
                    nextRank != null ? '$progress% to $nextRank Rank' : '100%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar track
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: MediaQuery.of(context).size.width * (progress / 100.0) * 0.8, // Approximation
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildMiniStatCard(
                          icon: Icons.trending_up,
                          label: 'ACTIVITY THIS MONTH',
                          value: activity,
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          icon: Icons.workspace_premium,
                          label: 'MEMBER SINCE',
                          value: memberSince,
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          icon: Icons.emoji_events,
                          label: 'REGION',
                          value: region,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return SizedBox(
      width: 145,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFourRanksCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The four Ranks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Posts, comments, reactions, and daily activity move you forward. Gold is reserved for accounts with three or more years of standing.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal scroll of the four ranks to guarantee no overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildRankItemCard(
                  title: 'Bronze',
                  duration: 'Few weeks',
                  color: const Color(0xFFC99843), // Bronze circle color
                  isCurrent: true,
                ),
                const SizedBox(width: 8),
                _buildRankItemCard(
                  title: 'Iron',
                  duration: 'A few months',
                  color: const Color(0xFF9CA3AF), // Iron color
                  isCurrent: false,
                ),
                const SizedBox(width: 8),
                _buildRankItemCard(
                  title: 'Silver',
                  duration: 'About a year',
                  color: const Color(0xFFD1D5DB), // Silver color
                  isCurrent: false,
                ),
                const SizedBox(width: 8),
                _buildRankItemCard(
                  title: 'Gold',
                  duration: '3 years +',
                  color: const Color(0xFFFBBF24), // Gold color
                  isCurrent: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItemCard({
    required String title,
    required String duration,
    required Color color,
    required bool isCurrent,
  }) {
    return Container(
      width: 100,
      height: 125, // Fixed height to keep all rank cards the exact same size
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFFAF8F4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xFFC99843) : const Color(0xFFE5E7EB),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank Color Circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          Text(
            duration,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          // Always render a placeholder of the same size to prevent height variance
          Text(
            isCurrent ? 'YOU ARE HERE' : '',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Color(0xFFC99843),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReputationGrowsCard() {
    final rules = [
      _XpRule(title: 'Daily check-in', cap: '1x/day', xp: '+10 XP'),
      _XpRule(
        title: 'Share a post with the community',
        cap: '5x/day',
        xp: '+20 XP',
      ),
      _XpRule(title: 'Share a story', cap: '3x/day', xp: '+15 XP'),
      _XpRule(
        title: 'Comment saved by 3+ others',
        cap: 'Once per comment',
        xp: '+25 XP',
      ),
      _XpRule(
        title: 'Your post saved by 5+ unique breeders',
        cap: 'Once per post',
        xp: '+30 XP',
      ),
      _XpRule(
        title: 'Mutual follow (both sides rewarded)',
        cap: 'Once per pair',
        xp: '+10 XP',
      ),
      _XpRule(title: 'Join a breeder club', cap: 'Once per club', xp: '+15 XP'),
      _XpRule(
        title: 'First post in a club',
        cap: 'Once per club',
        xp: '+20 XP',
      ),
      _XpRule(title: 'Start a new club', cap: 'Once per club', xp: '+50 XP'),
      _XpRule(title: 'Upload a farm photo', cap: '3x/day', xp: '+10 XP'),
      _XpRule(
        title: 'First Bantay conversation',
        cap: 'Once ever',
        xp: '+10 XP',
      ),
      _XpRule(
        title: '7-day check-in streak',
        cap: 'Once per streak',
        xp: '+25 XP',
      ),
      _XpRule(
        title: '30-day check-in streak',
        cap: 'Once per streak',
        xp: '+75 XP',
      ),
      _XpRule(title: 'Reach a new tier', cap: 'Once per tier', xp: '+200 XP'),
    ];

    final comingSoon = [
      _XpRule(
        title: 'My Farm — health logs, weight records, milestones',
        cap: '',
        xp: '+10 XP',
      ),
      _XpRule(
        title: 'My Farm — new bird added, hatch logs, banding',
        cap: '',
        xp: '+15 XP',
      ),
      _XpRule(
        title: 'Store — completed purchases (verified seller)',
        cap: '',
        xp: '+20 XP',
      ),
      _XpRule(
        title: 'Store — leaving a review on a fulfilled order',
        cap: '',
        xp: '+5 XP',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How reputation grows',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Daily caps keep the ladder honest. Spamming doesn\'t accelerate it.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Active rules
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    // Lightning bolt icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F4EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt, // Standard material bolt icon
                        size: 14,
                        color: Color(0xFF137333),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Activity name
                    Expanded(
                      child: Text(
                        rule.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Frequency Cap
                    Text(
                      rule.cap,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // XP value
                    Text(
                      rule.xp,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF137333),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Coming Soon Section with custom dashed border
          CustomPaint(
            painter: _DashedRectPainter(
              color: Colors.grey.shade300,
              borderRadius: 12,
              strokeWidth: 1,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comingSoon.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = comingSoon[index];
                      return Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            item.xp,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      );
                    },
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

class _XpRule {
  final String title;
  final String cap;
  final String xp;

  _XpRule({required this.title, required this.cap, required this.xp});
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  _DashedRectPainter({
    required this.color,
    this.borderRadius = 0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;

    // Drawing dashed rect border
    _drawDashedLine(
      canvas,
      paint,
      const Offset(0, 0),
      Offset(size.width, 0),
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, size.height),
      Offset(0, size.height),
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height),
      const Offset(0, 0),
      dashWidth,
      dashSpace,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    double dashWidth,
    double dashSpace,
  ) {
    double distance = (end - start).distance;
    double currentDistance = 0;
    final direction = (end - start) / distance;

    while (currentDistance < distance) {
      final endDistance = (currentDistance + dashWidth).clamp(0.0, distance);
      canvas.drawLine(
        start + direction * currentDistance,
        start + direction * endDistance,
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
