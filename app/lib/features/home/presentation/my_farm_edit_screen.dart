import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/farm_api.dart';

class MyFarmEditScreen extends StatefulWidget {
  const MyFarmEditScreen({super.key});

  @override
  State<MyFarmEditScreen> createState() => _MyFarmEditScreenState();
}

class _MyFarmEditScreenState extends State<MyFarmEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final FarmApi _farmApi = FarmApi();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String? _mobileNumber;
  String? _avatarUrl;
  String? _coverPhotoUrl;

  File? _selectedAvatar;
  File? _selectedCoverPhoto;

  @override
  void initState() {
    super.initState();
    _loadFarmData();
  }

  Future<void> _loadFarmData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _mobileNumber = prefs.getString('mobile_number');
      if (_mobileNumber != null) {
        final profile = await _farmApi.fetchFarm(mobileNumber: _mobileNumber!);
        if (profile != null) {
          _nameController.text = profile.name;
          _taglineController.text = profile.tagline;
          _storyController.text = profile.story;
          _cityController.text = profile.city;
          _provinceController.text = profile.province;
          _yearController.text = profile.startedYear != null && profile.startedYear! > 0
              ? profile.startedYear.toString()
              : '';
          _avatarUrl = profile.avatarUrl;
          _coverPhotoUrl = profile.coverPhotoUrl;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load farm: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(bool isCover) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isCover) {
          _selectedCoverPhoto = File(picked.path);
        } else {
          _selectedAvatar = File(picked.path);
        }
      });
    }
  }

  Future<void> _saveFarmData({bool publish = false}) async {
    if (_mobileNumber == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm Name is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _farmApi.saveFarm(
        mobileNumber: _mobileNumber!,
        name: name,
        tagline: _taglineController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        startedYear: int.tryParse(_yearController.text.trim()),
        story: _storyController.text.trim(),
      );

      if (_selectedAvatar != null || _selectedCoverPhoto != null) {
        await _farmApi.uploadFarmMedia(
          mobileNumber: _mobileNumber!,
          avatar: _selectedAvatar,
          coverPhoto: _selectedCoverPhoto,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(publish ? '🎉 Farm published successfully!' : '💾 Farm settings saved successfully!'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save farm: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _storyController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F2), // Premium soft background
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom Premium Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Farm Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // ── Profile Banner Stack (Cover & Founder overlap) ──
                          SizedBox(
                            height: 250,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Cover Photo (Banner)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 180,
                                  child: GestureDetector(
                                    onTap: () => _pickImage(true),
                                    child: Container(
                                      margin: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF8F4),
                                        borderRadius: BorderRadius.circular(16),
                                        image: _selectedCoverPhoto != null
                                            ? DecorationImage(
                                                image: FileImage(_selectedCoverPhoto!),
                                                fit: BoxFit.cover,
                                              )
                                            : (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty
                                                ? DecorationImage(
                                                    image: NetworkImage(_coverPhotoUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                      ),
                                      child: _selectedCoverPhoto == null && (_coverPhotoUrl == null || _coverPhotoUrl!.isEmpty)
                                          ? CustomPaint(
                                              painter: _DashRectPainter(
                                                color: const Color(0xFFC99843), // Golden border
                                                borderRadius: 16,
                                                strokeWidth: 2,
                                              ),
                                              child: Stack(
                                                children: [
                                                  const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(LucideIcons.image, size: 32, color: Color(0xFFC99843)),
                                                        SizedBox(height: 6),
                                                        Text(
                                                          'Cover Photo',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFFC99843),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Tap camera to upload',
                                                          style: TextStyle(fontSize: 10, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 12,
                                                    right: 12,
                                                    child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                                                      child: const Icon(LucideIcons.camera, size: 16, color: Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Stack(
                                              children: [
                                                Positioned(
                                                  bottom: 12,
                                                  right: 12,
                                                  child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                                                    child: const Icon(LucideIcons.camera, size: 16, color: Colors.black87),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),

                                // Founder Photo (Circular Overlay)
                                Positioned(
                                  top: 120,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () => _pickImage(false),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 110,
                                            height: 110,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFFAF8F4),
                                              border: Border.all(color: Colors.white, width: 4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              image: _selectedAvatar != null
                                                  ? DecorationImage(
                                                      image: FileImage(_selectedAvatar!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(_avatarUrl!),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null),
                                            ),
                                            child: _selectedAvatar == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                                                ? CustomPaint(
                                                    painter: _DashRectPainter(
                                                      color: Colors.grey.shade400,
                                                      isCircular: true,
                                                      strokeWidth: 1.5,
                                                    ),
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(LucideIcons.user, size: 28, color: Colors.grey),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            'Portrait',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: AppColors.accentGreen,
                                              child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Card 1: Basic Info ──
                          _buildCardWrapper(
                            title: 'Basic Information',
                            icon: LucideIcons.info,
                            children: [
                              _buildTextField(
                                label: 'Farm Name',
                                controller: _nameController,
                                hint: 'Enter your farm name',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Tagline',
                                subtitle: 'One short line shown under your name. Up to 160 characters.',
                                hint: 'What makes your farm unique?',
                                controller: _taglineController,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Established Year',
                                subtitle: 'When your farm started operating in the real world.',
                                controller: _yearController,
                                width: 140,
                                hint: 'e.g. 2016',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Card 2: Story & Location ──
                          _buildCardWrapper(
                            title: 'Story & Location',
                            icon: LucideIcons.mapPin,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'City',
                                      hint: 'e.g. San Pablo',
                                      controller: _cityController,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'Province / Region',
                                      hint: 'e.g. Laguna',
                                      controller: _provinceController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Our Story',
                                subtitle: 'Your journey, philosophy, what you\'re known for. At least 10 words to publish.',
                                hint: 'Tell visitors about your farm...',
                                controller: _storyController,
                                maxLines: 5,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Card 3: Showcase & Gallery ──
                          _buildCardWrapper(
                            title: 'Showcase & Gallery',
                            icon: LucideIcons.imagePlus,
                            children: [
                              _buildSectionHeader(
                                title: 'Farm Gallery',
                                subtitle: 'Facilities, animals, daily life. 0 photos uploaded.',
                              ),
                              const SizedBox(height: 8),
                              _buildUploadContainer(
                                height: 100,
                                icon: LucideIcons.imagePlus,
                                label: 'Add photos to gallery',
                                color: const Color(0xFFFAF8F4),
                              ),
                              const SizedBox(height: 24),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              const SizedBox(height: 16),
                              _buildSectionHeader(
                                title: 'Heritage Lines',
                                subtitle: 'Your signature breeding lines — the heritage your farm is known for. 0 listed.',
                              ),
                              const SizedBox(height: 12),
                              _buildAddButton(icon: LucideIcons.plus, label: 'Add heritage line'),
                              const SizedBox(height: 24),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              const SizedBox(height: 16),
                              _buildSectionHeader(
                                title: 'Featured Spotlight',
                                subtitle: 'Hand-picked stock you want visitors to see. 0 on showcase.',
                              ),
                              const SizedBox(height: 12),
                              _buildAddButton(icon: LucideIcons.plus, label: 'Feature a spotlight'),
                              const SizedBox(height: 24),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              const SizedBox(height: 16),
                              _buildSectionHeader(
                                title: 'Achievements',
                                subtitle: 'Show awards, recognitions, certifications. 0 listed.',
                              ),
                              const SizedBox(height: 12),
                              _buildAddButton(icon: LucideIcons.plus, label: 'Add achievement'),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      // ── Fixed Bottom Action Bar ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _saveFarmData(publish: false),
                  icon: const Icon(LucideIcons.save, size: 16),
                  label: const Text('Save draft'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    side: const BorderSide(color: AppColors.accentGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _saveFarmData(publish: true),
                  icon: const Icon(LucideIcons.send, size: 16),
                  label: const Text('Publish farm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.golden,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accentGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadContainer({
    required double height,
    double? width,
    bool isCircular = false,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _DashRectPainter(
          color: Colors.grey.shade300,
          isCircular: isCircular,
          borderRadius: 12,
          strokeWidth: 1.5,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.grey.shade500),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({required IconData icon, required String label}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentGreen,
        side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? subtitle,
    String? hint,
    required TextEditingController controller,
    int maxLines = 1,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashRectPainter extends CustomPainter {
  final Color color;
  final bool isCircular;
  final double borderRadius;
  final double strokeWidth;

  _DashRectPainter({
    required this.color,
    this.isCircular = false,
    this.borderRadius = 0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (isCircular) {
      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width / 2;
      final circumference = 2 * 3.14159 * radius;
      final dashCount = (circumference / 10).floor();
      final dashAngle = 2 * 3.14159 / dashCount;
      
      for (var i = 0; i < dashCount; i++) {
        if (i % 2 == 0) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            i * dashAngle,
            dashAngle,
            false,
            paint,
          );
        }
      }
    } else {
      const dashWidth = 5.0;
      const dashSpace = 5.0;
      
      // Draw top line
      _drawDashedLine(canvas, paint, const Offset(0, 0), Offset(size.width, 0), dashWidth, dashSpace);
      // Draw right line
      _drawDashedLine(canvas, paint, Offset(size.width, 0), Offset(size.width, size.height), dashWidth, dashSpace);
      // Draw bottom line
      _drawDashedLine(canvas, paint, Offset(size.width, size.height), Offset(0, size.height), dashWidth, dashSpace);
      // Draw left line
      _drawDashedLine(canvas, paint, Offset(0, size.height), const Offset(0, 0), dashWidth, dashSpace);
    }
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end, double dashWidth, double dashSpace) {
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
