import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/club_api.dart';
import 'region_picker.dart';

class CreateClubModal extends StatefulWidget {
  const CreateClubModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateClubModal(),
    );
  }

  @override
  State<CreateClubModal> createState() => _CreateClubModalState();
}

class _CreateClubModalState extends State<CreateClubModal> {
  final ClubApi _clubApi = ClubApi();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> _bloodlines = [
    'Kelso', 'Sweater', 'Hatch', 'Roundhead', 'Albany', 'Lemon',
    'Grey', 'Radio', 'Claret', 'Butcher', 'Other'
  ];
  
  final Set<String> _selectedBloodlines = {};
  bool _isPublic = true;
  bool _verifiedOnly = false;
  String _selectedRegion = '';
  int _minBirds = 0;
  String? _coverPhotoPath;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club name is required.')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber = prefs.getString('auth_mobile_number') ?? '';
      
      final category = _selectedBloodlines.isNotEmpty ? 'Bloodline' : 'Community';

      await _clubApi.createClub(
        mobileNumber: mobileNumber,
        name: name,
        description: _descController.text.trim(),
        category: category,
        region: _selectedRegion,
        focusTags: _selectedBloodlines.toList(),
        isPublic: _isPublic,
        minBirds: _minBirds,
        verifiedOnly: _verifiedOnly,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Club',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, size: 18, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Photo
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          _coverPhotoPath = result.files.single.path;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        image: _coverPhotoPath != null
                            ? DecorationImage(
                                image: FileImage(File(_coverPhotoPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverPhotoPath == null
                          ? CustomPaint(
                              painter: _DashRectPainter(color: Colors.grey.shade400),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.camera, size: 24, color: Colors.grey.shade500),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Upload Cover Photo',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upload will land next session',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Club Name
                  _buildLabel('CLUB NAME', required: true),
                  _buildTextField(controller: _nameController, hint: 'e.g. Pampanga Breeders Alliance'),
                  const SizedBox(height: 20),
                  
                  // Description
                  _buildLabel('DESCRIPTION'),
                  _buildTextField(controller: _descController, hint: 'What is this club about?', maxLines: 4),
                  const SizedBox(height: 20),
                  
                  // Category
                  _buildLabel('CATEGORY', required: true),
                  _buildTextField(hint: _selectedBloodlines.isNotEmpty ? 'Bloodline' : 'Community', readOnly: true),
                  const SizedBox(height: 20),
                  
                  // Bloodline Focus
                  _buildLabel('BLOODLINE FOCUS'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bloodlines.map((b) => _buildBloodlineChip(b)).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecting any bloodline switches the club category to Bloodline automatically.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  
                  // Region
                  _buildLabel('REGION'),
                  RegionPicker(
                    selectedValue: _selectedRegion.isEmpty ? null : _selectedRegion,
                    onSelected: (val) => setState(() => _selectedRegion = val),
                  ),
                  const SizedBox(height: 20),
                  
                  // Privacy
                  _buildLabel('PRIVACY'),
                  Row(
                    children: [
                      Expanded(child: _buildPrivacyOption(true, 'Public', LucideIcons.globe)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPrivacyOption(false, 'Private', LucideIcons.lock)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anyone can find and join this club.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  
                  // Membership Requirements
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Membership Requirements (optional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Min. registered birds',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                            const Spacer(),
                            // Compact +/- stepper
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _StepperButton(
                                    icon: LucideIcons.minus,
                                    onTap: () => setState(() {
                                      if (_minBirds > 0) _minBirds--;
                                    }),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '$_minBirds',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  _StepperButton(
                                    icon: LucideIcons.plus,
                                    onTap: () => setState(() => _minBirds++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _verifiedOnly,
                                onChanged: (val) => setState(() => _verifiedOnly = val ?? false),
                                activeColor: AppColors.accentGreen,
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Verified breeders only',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Create Club',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, TextEditingController? controller, int maxLines = 1, bool readOnly = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
    );
  }

  Widget _buildBloodlineChip(String label) {
    final isSelected = _selectedBloodlines.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedBloodlines.remove(label);
          } else {
            _selectedBloodlines.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGreen : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(bool isPublic, String label, IconData icon) {
    final isSelected = _isPublic == isPublic;
    return GestureDetector(
      onTap: () => setState(() => _isPublic = isPublic),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accentGreen : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accentGreen : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Icon(icon, size: 14, color: Colors.grey.shade600),
      ),
    );
  }
}

class _DashRectPainter extends CustomPainter {
  final Color color;

  _DashRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

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
