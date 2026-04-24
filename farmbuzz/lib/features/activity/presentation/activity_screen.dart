import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/activity/domain/models/activity_item.dart';
import 'package:farmbuzz/features/activity/presentation/widgets/activity_card.dart';
import 'package:farmbuzz/features/activity/presentation/widgets/summary_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedFilter = 'All';

  final List<ActivityItem> _activities = [
    ActivityItem(
      title: 'Logged health record',
      description: 'Thunder — weight 2.4kg, alert, eating well.',
      xp: 25,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.edit_outlined,
      iconBgColor: Colors.redAccent,
    ),
    ActivityItem(
      title: 'Created a post',
      description: '"Morning update: Black Warrior hit target weight for the month"',
      xp: 20,
      type: ActivityType.posts,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.create_outlined,
      iconBgColor: Colors.green,
    ),
    ActivityItem(
      title: 'Liked a post',
      description: 'Maria Santos\' post about Kelso bloodlines',
      xp: 0,
      type: ActivityType.social,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      icon: Icons.favorite_border,
      iconBgColor: Colors.pinkAccent,
    ),
    ActivityItem(
      title: 'Documented vaccination',
      description: '3 birds — Newcastle Disease booster',
      xp: 45,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.edit_outlined,
      iconBgColor: Colors.blueAccent,
    ),
    ActivityItem(
      title: 'Commented on a post',
      description: 'Replied to Triple J Farm: "Thanks for the feeding tip!"',
      xp: 0,
      type: ActivityType.social,
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
      icon: Icons.chat_bubble_outline,
      iconBgColor: Colors.teal,
    ),
  ];

  final List<ActivityItem> _thisWeekActivities = [
    ActivityItem(
      title: 'Added a new bird',
      description: 'Ruby — Kelso x Sweater, hatched Mar 28 2026',
      xp: 75,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.local_offer_outlined,
      iconBgColor: Colors.orange,
    ),
    ActivityItem(
      title: 'Shared a breeding tip',
      description: 'Best practices for incubation humidity',
      xp: 15,
      type: ActivityType.posts,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.lightbulb_outline,
      iconBgColor: Colors.amber,
    ),
    ActivityItem(
      title: 'Started a breeding program',
      description: 'Thunder × Ruby — scheduled for April 20',
      xp: 50,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.track_changes,
      iconBgColor: Colors.green,
    ),
    ActivityItem(
      title: 'Posted a photo',
      description: 'New batch of chicks looking healthy!',
      xp: 10,
      type: ActivityType.posts,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.image_outlined,
      iconBgColor: Colors.blue,
    ),
  ];

  final List<ActivityItem> _earlierActivities = [
    ActivityItem(
      title: 'Completed a breeding program',
      description: 'Shadow × Luna — 8 chicks hatched (87% success)',
      xp: 100,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      icon: Icons.track_changes,
      iconBgColor: Colors.green,
    ),
    ActivityItem(
      title: 'Updated farm profile',
      description: 'Added new location and contact details',
      xp: 0,
      type: ActivityType.farm,
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      icon: Icons.storefront_outlined,
      iconBgColor: Colors.brown,
    ),
  ];

  List<ActivityItem> _getFilteredActivities(List<ActivityItem> list) {
    if (_selectedFilter == 'All') return list;
    
    final Map<String, ActivityType> filterMap = {
      'Farm': ActivityType.farm,
      'Posts': ActivityType.posts,
      'Social': ActivityType.social,
    };
    
    final targetType = filterMap[_selectedFilter];
    return list.where((item) => item.type == targetType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredToday = _getFilteredActivities(_activities);
    final filteredThisWeek = _getFilteredActivities(_thisWeekActivities);
    final filteredEarlier = _getFilteredActivities(_earlierActivities);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A timeline of everything\nyou\'ve done on FarmBuzz',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.file_download_outlined, size: 18, color: AppColors.accentGreen),
                        label: Text(
                          'Export CSV',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.accentGreen.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Summary Cards Row
                  const Row(
                    children: [
                      SummaryCard(
                        label: 'TOTAL ACTIONS',
                        value: '11',
                        valueColor: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 12),
                      SummaryCard(
                        label: 'XP EARNED',
                        value: '+315',
                        valueColor: Color(0xFFD97706),
                      ),
                      SizedBox(width: 12),
                      SummaryCard(
                        label: 'TIME RANGE',
                        value: '30 days',
                        valueColor: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 11),
                        _buildFilterChip('Farm', 6),
                        _buildFilterChip('Posts', 3),
                        _buildFilterChip('Social', 2),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time Range Dropdown Placeholder
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            'Last 30 days',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Activity List Grouped by Date
            if (filteredToday.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[50],
                width: double.infinity,
                child: Text(
                  'TODAY · ${filteredToday.length} ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredToday.length,
                itemBuilder: (context, index) {
                  return ActivityCard(item: filteredToday[index]);
                },
              ),
              const SizedBox(height: 16),
            ],
            
            if (filteredThisWeek.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[50],
                width: double.infinity,
                child: Text(
                  'THIS WEEK · ${filteredThisWeek.length} ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredThisWeek.length,
                itemBuilder: (context, index) {
                  return ActivityCard(item: filteredThisWeek[index]);
                },
              ),
              const SizedBox(height: 16),
            ],
            
            if (filteredEarlier.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[50],
                width: double.infinity,
                child: Text(
                  'EARLIER · ${filteredEarlier.length} ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEarlier.length,
                itemBuilder: (context, index) {
                  return ActivityCard(item: filteredEarlier[index]);
                },
              ),
            ],
            
            if (filteredToday.isEmpty && filteredThisWeek.isEmpty && filteredEarlier.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No activities found for this filter.',
                        style: GoogleFonts.inter(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.accentGreen : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
