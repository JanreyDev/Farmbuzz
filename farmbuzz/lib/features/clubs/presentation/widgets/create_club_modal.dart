import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

/// A premium modal for creating new clubs.
/// Features cover photo upload, bloodline selection, privacy toggles, and membership requirements.
class CreateClubModal extends StatefulWidget {
  const CreateClubModal({super.key, this.onClubCreated});

  final void Function(Map<String, dynamic> clubData)? onClubCreated;

  /// Static utility to show the create club modal.
  static void show(BuildContext context, {void Function(Map<String, dynamic> clubData)? onClubCreated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => CreateClubModal(onClubCreated: onClubCreated),
    );
  }

  @override
  State<CreateClubModal> createState() => _CreateClubModalState();
}

class _CreateClubModalState extends State<CreateClubModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minBirdsController = TextEditingController(text: '0');
  
  XFile? _coverImage;
  final ImagePicker _picker = ImagePicker();

  bool _isPublic = true;
  bool _isVerifiedOnly = false;
  bool _canCreate = false;
  String _selectedCategory = 'Community';
  final Set<String> _selectedBloodlines = {};

  final List<String> _bloodlines = [
    'Kelso', 'Sweater', 'Hatch', 'Roundhead', 'Albany', 'Lemon', 
    'Grey', 'Radio', 'Claret', 'Butcher', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    _descriptionController.dispose();
    _minBirdsController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _canCreate = _nameController.text.trim().isNotEmpty;
    });
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = image;
        });
      }
    } catch (e) {
      debugPrint("Error picking cover image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoUpload(),
                  const SizedBox(height: 24),
                  _buildLabel('CLUB NAME', isRequired: true),
                  _buildTextField(_nameController, hint: 'e.g. Pampanga Breeders Alliance'),
                  const SizedBox(height: 20),
                  _buildLabel('DESCRIPTION'),
                  _buildTextField(_descriptionController, hint: 'What is this club about?', maxLines: 4),
                  const SizedBox(height: 20),
                  _buildLabel('CATEGORY', isRequired: true),
                  _buildDropdown(_selectedCategory, (val) => setState(() => _selectedCategory = val!)),
                  const SizedBox(height: 20),
                  _buildLabel('BLOODLINE FOCUS'),
                  _buildBloodlineChips(),
                  const SizedBox(height: 20),
                  _buildLabel('REGION'),
                  _buildTextField(TextEditingController(), hint: 'Select region', readOnly: true, suffix: Icons.arrow_drop_down),
                  const SizedBox(height: 20),
                  _buildLabel('PRIVACY'),
                  _buildPrivacySelector(),
                  const SizedBox(height: 24),
                  _buildMembershipRequirements(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildCreateButton(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'Create Club',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          image: _coverImage != null
              ? DecorationImage(
                  image: FileImage(File(_coverImage!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _coverImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Cover Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Tap to select an image',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, int maxLines = 1, bool readOnly = false, IconData? suffix}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: suffix != null ? Icon(suffix, color: Colors.grey[400]) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          onChanged: onChanged,
          items: ['Community', 'Business', 'Educational'].map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBloodlineChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _bloodlines.map((bloodline) {
        final isSelected = _selectedBloodlines.contains(bloodline);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBloodlines.remove(bloodline);
              } else {
                _selectedBloodlines.add(bloodline);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accentGreen : Colors.grey[200]!,
              ),
            ),
            child: Text(
              bloodline,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.accentGreen : Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrivacySelector() {
    return Row(
      children: [
        Expanded(
          child: _PrivacyOption(
            label: 'Public',
            icon: Icons.public,
            isActive: _isPublic,
            onTap: () => setState(() => _isPublic = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrivacyOption(
            label: 'Private',
            icon: Icons.lock_outline,
            isActive: !_isPublic,
            onTap: () => setState(() => _isPublic = false),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership Requirements (optional)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min. registered birds',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: TextField(
                  controller: _minBirdsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.accentGreen),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _isVerifiedOnly,
                  activeColor: AppColors.accentGreen,
                  onChanged: (val) => setState(() => _isVerifiedOnly = val!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Verified breeders only',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _canCreate ? _handleCreate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canCreate ? AppColors.accentGreen : Colors.grey[100],
            foregroundColor: _canCreate ? Colors.white : Colors.grey[400],
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Create Club',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreate() {
    final clubData = {
      'title': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'bloodlines': _selectedBloodlines.toList(),
      'isPublic': _isPublic,
      'minBirds': int.tryParse(_minBirdsController.text) ?? 0,
      'verifiedOnly': _isVerifiedOnly,
      'imageUrl': _coverImage?.path,
    };
    
    widget.onClubCreated?.call(clubData);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Club created successfully! waiting for admin approval'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accentGreen : Colors.grey[200]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? AppColors.accentGreen : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isActive ? AppColors.accentGreen : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
