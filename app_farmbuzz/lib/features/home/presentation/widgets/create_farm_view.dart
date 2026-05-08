import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

class CreateFarmView extends StatefulWidget {
  const CreateFarmView({
    super.key, 
    required this.onBack,
    required this.onCreated,
  });

  final VoidCallback onBack;
  final ValueChanged<Map<String, dynamic>> onCreated;

  @override
  State<CreateFarmView> createState() => _CreateFarmViewState();
}

class _CreateFarmViewState extends State<CreateFarmView> {
  int? _selectedTypeIndex;
  int _currentStep = 1;
  
  final _farmNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _yearController = TextEditingController(text: '2026');

  @override
  void initState() {
    super.initState();
    _farmNameController.addListener(() => setState(() {}));
    _cityController.addListener(() => setState(() {}));
    _yearController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _farmNameController.dispose();
    _cityController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _farmNameController.text.isNotEmpty && 
           _cityController.text.isNotEmpty && 
           _yearController.text.isNotEmpty;
  }

  final List<Map<String, dynamic>> _farmTypes = [
    {
      'title': 'Gamefowl (Heritage Breeder)',
      'description': 'Lineage tracking, individual bird records, QR certificates.',
      'highlight': 'For farmers tracking lineage records for documentation and sales.',
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
  ];  bool _showSuccess = false;

  void _handleCreateFarm() async {
    setState(() => _showSuccess = true);
    // Show toast for 2 seconds then navigate
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      widget.onCreated({
        'name': _farmNameController.text.trim(),
        'farm_type': _selectedTypeIndex != null
            ? (_farmTypes[_selectedTypeIndex!]['title'] as String)
            : null,
        'city': _cityController.text.trim(),
        'started_year': int.tryParse(_yearController.text.trim()),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                          onTap: _currentStep == 1 
                            ? widget.onBack 
                            : () => setState(() => _currentStep = 1),
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
                              'Setup step $_currentStep of 2',
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
                  child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ],
          ),
        ),
        if (_showSuccess)
          _SuccessToast(
            farmName: _farmNameController.text,
            onClose: () => setState(() => _showSuccess = false),
          ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
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
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: _farmTypes.length,
          itemBuilder: (context, index) {
            return _FarmTypeCard(
              type: _farmTypes[index],
              isSelected: _selectedTypeIndex == index,
              onTap: () => setState(() => _selectedTypeIndex = index),
              icon: index == 0 ? Icons.history_edu_rounded : null,
            );
          },
        ),
        const SizedBox(height: 12),
        
        // Footer (Step 1)
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
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Continue',
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
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your farm details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A name, a location, the year you started, and how big your operation is. Every field is required except size.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('NAME'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel('FARM NAME *'),
                  Text('${_farmNameController.text.length} / 120', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField('e.g. Primex Gamefarm', controller: _farmNameController),
              
              const SizedBox(height: 24),
              _buildSectionLabel('WHERE'),
              const SizedBox(height: 12),
              _buildInputLabel('CITY OR MUNICIPALITY *'),
              const SizedBox(height: 8),
              _buildTextField('Search 1,634 cities and municipalities...', icon: Icons.location_on_outlined, controller: _cityController),
              
              const SizedBox(height: 16),
              _buildInputLabel('BARANGAY'),
              const SizedBox(height: 8),
              _buildTextField(
                'Pick a city first to see barangays', 
                isEnabled: false, 
                fillColor: const Color(0xFFF3EFE7),
                hintColor: const Color(0xFFB6B8B6),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional — kept private. Pick from the list, or type a sitio/purok not shown.',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
              
              const SizedBox(height: 24),
              _buildSectionLabel('SCALE'),
              const SizedBox(height: 12),
              _buildInputLabel('YEAR ESTABLISHED *'),
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: _buildTextField('2026', controller: _yearController),
              ),
              const SizedBox(height: 8),
              Text(
                'Any year between 1900 and 2026.',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
              
              const SizedBox(height: 16),
              _buildInputLabel('FARM SIZE'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSizeOption('Small', 'Under 50 birds')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSizeOption('Medium', '50 to 200 birds')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSizeOption('Large', '200+ birds')),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Optional. Used to benchmark you against farms of similar scale.',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFEF08A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: Color(0xFF854D0E), size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF854D0E),
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'Privacy: ', style: TextStyle(fontWeight: FontWeight.w800)),
                      TextSpan(text: 'only your province ever shows publicly. Your city and barangay stay private — that\'s what protects your flock from theft.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isFormValid ? _handleCreateFarm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create farm',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.accentGreen,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? icon, bool isEnabled = true, Color? fillColor, Color? hintColor, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor ?? (isEnabled ? Colors.grey[400] : Colors.grey[300]),
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: icon != null 
          ? Icon(icon, size: 18, color: Colors.grey[400]) 
          : null,
        filled: true,
        fillColor: fillColor ?? (isEnabled ? Colors.white : const Color(0xFFF5F5F5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmTypeCard extends StatelessWidget {
  const _FarmTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final Map<String, dynamic> type;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: type['color'] as Color, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            color: (type['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon ?? (type['icon'] as IconData),
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
  }
}

class _SuccessToast extends StatelessWidget {
  const _SuccessToast({
    required this.farmName,
    required this.onClose,
  });

  final String farmName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Farm created',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '$farmName is ready. Let\'s add your first birds.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
