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
  final List<_AchievementItem> _achievements = [];

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
      _mobileNumber = prefs.getString('auth_mobile_number') ?? prefs.getString('mobile_number');
      
      // Fallback to local storage first
      _nameController.text = prefs.getString('farm_name') ?? '';
      _taglineController.text = prefs.getString('farm_tagline') ?? '';
      _cityController.text = prefs.getString('farm_city') ?? '';
      _provinceController.text = prefs.getString('farm_province') ?? '';
      final cachedYear = prefs.getInt('farm_year') ?? 0;
      _yearController.text = cachedYear > 0 ? cachedYear.toString() : '';
      
      final localCover = prefs.getString('farm_cover_photo');
      if (localCover != null && localCover.isNotEmpty) {
        _selectedCoverPhoto = File(localCover);
      }
      _coverPhotoUrl = prefs.getString('farm_cover_photo_url');

      if (_mobileNumber != null) {
        final profile = await _farmApi.fetchFarm(mobileNumber: _mobileNumber!);
        if (profile != null) {
          if (profile.name.isNotEmpty) _nameController.text = profile.name;
          if (profile.tagline.isNotEmpty) _taglineController.text = profile.tagline;
          if (profile.story.isNotEmpty) _storyController.text = profile.story;
          if (profile.city.isNotEmpty) _cityController.text = profile.city;
          if (profile.province.isNotEmpty) _provinceController.text = profile.province;
          if (profile.startedYear != null && profile.startedYear! > 0) {
            _yearController.text = profile.startedYear.toString();
          }
          if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
            _avatarUrl = profile.avatarUrl;
          }
          if (profile.coverPhotoUrl != null && profile.coverPhotoUrl!.isNotEmpty) {
            _coverPhotoUrl = profile.coverPhotoUrl;
            _selectedCoverPhoto = null; // Prefer remote URL if available
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load farm: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(bool isCover) async {
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _saveFarmData({bool publish = false}) async {
    if (_mobileNumber == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Farm Name is required')));
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
            content: Text(
              publish
                  ? '🎉 Farm published successfully!'
                  : '💾 Farm settings saved successfully!',
            ),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save farm: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddAchievementModal() async {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    DateTime? selectedDate;
    bool isSaving = false;

    Future<void> pickDate(StateSetter setModalState) async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? now,
        firstDate: DateTime(1990),
        lastDate: DateTime(now.year + 2),
      );
      if (picked != null) {
        setModalState(() => selectedDate = picked);
      }
    }

    String formatDate(DateTime date) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$month/$day/$year';
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final canAdd =
                titleController.text.trim().isNotEmpty &&
                selectedDate != null &&
                !isSaving;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFCFA),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD4E3D6)),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Color(0xFF0E6B3A), Color(0xFF1A8A4E)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Add Achievement',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Text(
                        'Capture key awards and recognitions to showcase your farm credibility.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                      child: _buildModalInputField(
                        controller: titleController,
                        label: 'Title',
                        hint: 'Title (e.g. 1st Place - Regional Show)',
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: _buildModalInputField(
                        controller: detailController,
                        label: 'Location / detail',
                        hint: 'Location or detail (optional)',
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => pickDate(setModalState),
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: selectedDate == null
                                      ? 'mm/dd/yyyy'
                                      : formatDate(selectedDate!),
                                  suffixIcon: const Icon(
                                    LucideIcons.calendar,
                                    size: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD4DDD4),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.accentGreen,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: canAdd
                                  ? () async {
                                      setModalState(() => isSaving = true);
                                      setState(() {
                                        _achievements.add(
                                          _AchievementItem(
                                            title: titleController.text.trim(),
                                            detail: detailController.text
                                                .trim(),
                                            date: selectedDate!,
                                          ),
                                        );
                                      });
                                      if (mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    }
                                  : null,
                              icon: const Icon(LucideIcons.plus, size: 14),
                              label: const Text('Save'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Wait for the dialog exit animation to finish before disposing controllers
    await Future.delayed(const Duration(milliseconds: 300));
    titleController.dispose();
    detailController.dispose();
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
                      child: Icon(
                        LucideIcons.arrowLeft,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
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
                                                image: FileImage(
                                                  _selectedCoverPhoto!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : (_coverPhotoUrl != null &&
                                                      _coverPhotoUrl!.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        _coverPhotoUrl!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null),
                                      ),
                                      child:
                                          _selectedCoverPhoto == null &&
                                              (_coverPhotoUrl == null ||
                                                  _coverPhotoUrl!.isEmpty)
                                          ? CustomPaint(
                                              painter: _DashRectPainter(
                                                color: const Color(
                                                  0xFFC99843,
                                                ), // Golden border
                                                borderRadius: 16,
                                                strokeWidth: 2,
                                              ),
                                              child: Stack(
                                                children: [
                                                  const Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          LucideIcons.image,
                                                          size: 32,
                                                          color: Color(
                                                            0xFFC99843,
                                                          ),
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text(
                                                          'Cover Photo',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                              0xFFC99843,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Tap camera to upload',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 12,
                                                    right: 12,
                                                    child: CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: Colors
                                                          .white
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                      child: const Icon(
                                                        LucideIcons.camera,
                                                        size: 16,
                                                        color: Colors.black87,
                                                      ),
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
                                                    backgroundColor: Colors
                                                        .white
                                                        .withValues(alpha: 0.9),
                                                    child: const Icon(
                                                      LucideIcons.camera,
                                                      size: 16,
                                                      color: Colors.black87,
                                                    ),
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
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              image: _selectedAvatar != null
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                        _selectedAvatar!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (_avatarUrl != null &&
                                                            _avatarUrl!
                                                                .isNotEmpty
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                              _avatarUrl!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null),
                                            ),
                                            child:
                                                _selectedAvatar == null &&
                                                    (_avatarUrl == null ||
                                                        _avatarUrl!.isEmpty)
                                                ? CustomPaint(
                                                    painter: _DashRectPainter(
                                                      color:
                                                          Colors.grey.shade400,
                                                      isCircular: true,
                                                      strokeWidth: 1.5,
                                                    ),
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            LucideIcons.user,
                                                            size: 28,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            'Portrait',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
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
                                              backgroundColor:
                                                  AppColors.accentGreen,
                                              child: const Icon(
                                                LucideIcons.camera,
                                                size: 14,
                                                color: Colors.white,
                                              ),
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
                                subtitle:
                                    'One short line shown under your name. Up to 160 characters.',
                                hint: 'What makes your farm unique?',
                                controller: _taglineController,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Established Year',
                                subtitle:
                                    'When your farm started operating in the real world.',
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
                                subtitle:
                                    'Your journey, philosophy, what you\'re known for. At least 10 words to publish.',
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
                                title: 'Achievements',
                                subtitle:
                                    'Show awards, recognitions, certifications. ${_achievements.length} listed.',
                              ),
                              const SizedBox(height: 12),
                              _buildAddButton(
                                icon: LucideIcons.plus,
                                label: 'Add achievement',
                                onPressed: _showAddAchievementModal,
                              ),
                              if (_achievements.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                ..._achievements.map(
                                  (item) => _buildAchievementTile(item),
                                ),
                              ],
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
                  onPressed: _isLoading
                      ? null
                      : () => _saveFarmData(publish: false),
                  icon: const Icon(LucideIcons.save, size: 16),
                  label: const Text('Save draft'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    side: const BorderSide(
                      color: AppColors.accentGreen,
                      width: 1.5,
                    ),
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
                  onPressed: _isLoading
                      ? null
                      : () => _saveFarmData(publish: true),
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
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
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildModalInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4DDD4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(_AchievementItem item) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dateLabel = '${months[item.date.month - 1]} ${item.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6), // Light yellow/orange
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.trophy,
              color: Color(0xFFD97706), // Golden/Bronze
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (item.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.detail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Delete Icon
          GestureDetector(
            onTap: () {
              setState(() {
                _achievements.remove(item);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                LucideIcons.trash2,
                color: Colors.red.shade400,
                size: 18,
              ),
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
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementItem {
  final String title;
  final String detail;
  final DateTime date;

  const _AchievementItem({
    required this.title,
    required this.detail,
    required this.date,
  });
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
      _drawDashedLine(
        canvas,
        paint,
        const Offset(0, 0),
        Offset(size.width, 0),
        dashWidth,
        dashSpace,
      );
      // Draw right line
      _drawDashedLine(
        canvas,
        paint,
        Offset(size.width, 0),
        Offset(size.width, size.height),
        dashWidth,
        dashSpace,
      );
      // Draw bottom line
      _drawDashedLine(
        canvas,
        paint,
        Offset(size.width, size.height),
        Offset(0, size.height),
        dashWidth,
        dashSpace,
      );
      // Draw left line
      _drawDashedLine(
        canvas,
        paint,
        Offset(0, size.height),
        const Offset(0, 0),
        dashWidth,
        dashSpace,
      );
    }
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
