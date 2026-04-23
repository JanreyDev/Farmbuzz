import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class CreateFarmView extends StatefulWidget {
  const CreateFarmView({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CreateFarmView> createState() => _CreateFarmViewState();
}

class _CreateFarmViewState extends State<CreateFarmView> {
  int? _selectedTypeIndex;
  int _currentStep = 1;

  final List<Map<String, dynamic>> _farmTypes = [
    {
      'title': 'Gamefowl (Heritage Breeder)',
      'description': 'Lineage tracking, individual bird records, QR certificates.',
      'highlight': 'For breeders preserving bloodlines for show or sale.',
      'icon': Icons.flutter_dash_outlined,
      'color': const Color(0xFFA26543),
      'borderColor': AppColors.golden,
    },
    {
      'title': 'Layer Poultry (Eggs)',
      'description': 'Flock group tracking, lay rate, feed conversion.',
      'highlight': 'For farms producing table eggs at commercial scale.',
      'icon': Icons.egg_outlined,
      'color': const Color(0xFFB48634),
    },
    {
      'title': 'Broiler Poultry (Meat)',
      'description': 'Batch tracking, FCR, days-to-market economics.',
      'highlight': 'For farms raising birds for meat production.',
      'icon': Icons.bakery_dining_outlined,
      'color': const Color(0xFFAE6005),
    },
    {
      'title': 'Heritage / Backyard',
      'description': 'Flexible mix — eggs, meat, pets, native breeds.',
      'highlight': 'For backyard keepers and small heritage flocks.',
      'icon': Icons.home_outlined,
      'color': const Color(0xFF5A7759),
    },
    {
      'title': 'Mixed Farm',
      'description': 'Track each species separately under one unified dashboard.',
      'highlight': 'For farms keeping multiple species on one property.',
      'icon': Icons.grid_view_rounded,
      'color': const Color(0xFF169846),
      'borderColor': const Color(0xFF169846),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your first farm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Step 1 of 2',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _currentStep == 1 ? 0.5 : 1.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tag_rounded, color: Color(0xFF16A34A), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'WHAT MY FARM SUPPORTS',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF16A34A),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Five kinds of farms. One serious toolkit.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'My Farm is built for every kind of Filipino breeder. Each module is a complete toolkit — birds, breeding, health, certificates, team, and reports.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _farmTypes.length,
                    itemBuilder: (context, index) {
                      final type = _farmTypes[index];
                      final isSelected = _selectedTypeIndex == index;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTypeIndex = index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top border bar
                              Container(
                                height: 4,
                                color: type['color'] as Color,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: type['color'] as Color,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (type['color'] as Color).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          index == 0 ? Icons.history_edu_rounded : (type['icon'] as IconData),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        type['title'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        type['description'] as String,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                          height: 1.4,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[200]!, width: 1),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 1),
                                              child: Icon(
                                                Icons.adjust_rounded,
                                                color: type['color'] as Color,
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                type['highlight'] as String,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.3,
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Footer (Now part of scroll)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'UP NEXT',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentGreen,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Farm details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accentGreen),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep == 1) {
                              setState(() => _currentStep = 2);
                            } else {
                              // Finalize logic for Step 2
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.accentGreen.withValues(alpha: 0.3),
                            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currentStep == 1 ? 'Continue' : 'Finish',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
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
