import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/profile_api.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearsBreedingController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bloodlinesController = TextEditingController();
  final TextEditingController _socialFbController = TextEditingController();
  final TextEditingController _socialIgController = TextEditingController();
  final TextEditingController _socialTiktokController = TextEditingController();
  final TextEditingController _socialYtController = TextEditingController();
  final TextEditingController _socialWebController = TextEditingController();

  final ProfileApi _profileApi = ProfileApi();
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _mobileNumber =
          prefs.getString('auth_mobile_number') ??
          prefs.getString('mobile_number');

      // Fallback to local storage first
      _nameController.text = prefs.getString('profile_name') ?? '';
      _yearsBreedingController.text =
          prefs.getString('profile_years_breeding') ?? '';
      _bioController.text = prefs.getString('profile_bio') ?? '';
      _addressController.text = prefs.getString('profile_address') ?? '';
      _bloodlinesController.text = prefs.getString('profile_bloodlines') ?? '';

      final localCover = prefs.getString('profile_cover_photo');
      if (localCover != null && localCover.isNotEmpty) {
        _selectedCoverPhoto = File(localCover);
      }
      _coverPhotoUrl = prefs.getString('profile_cover_photo_url');
      _avatarUrl = prefs.getString('profile_avatar_url');

      if (_mobileNumber != null) {
        final profile = await _profileApi.fetchProfile(
          mobileNumber: _mobileNumber!,
        );
        if (profile != null) {
          if (profile.name.isNotEmpty) _nameController.text = profile.name;
          if (profile.yearsBreeding != null)
            _yearsBreedingController.text = profile.yearsBreeding!;
          if (profile.bio != null) _bioController.text = profile.bio!;
          if (profile.address != null)
            _addressController.text = profile.address!;
          if (profile.bloodlines != null)
            _bloodlinesController.text = profile.bloodlines!;
          if (profile.socialFb != null)
            _socialFbController.text = profile.socialFb!;
          if (profile.socialIg != null)
            _socialIgController.text = profile.socialIg!;
          if (profile.socialTiktok != null)
            _socialTiktokController.text = profile.socialTiktok!;
          if (profile.socialYt != null)
            _socialYtController.text = profile.socialYt!;
          if (profile.socialWeb != null)
            _socialWebController.text = profile.socialWeb!;

          if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
            _avatarUrl = profile.avatarUrl;
            _selectedAvatar = null;
          }
          if (profile.coverPhotoUrl != null &&
              profile.coverPhotoUrl!.isNotEmpty) {
            _coverPhotoUrl = profile.coverPhotoUrl;
            _selectedCoverPhoto = null;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
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

  Future<void> _saveProfileData() async {
    if (_mobileNumber == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Display Name is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _profileApi.updateProfile(
        mobileNumber: _mobileNumber!,
        name: name,
        yearsBreeding: _yearsBreedingController.text.trim(),
        bio: _bioController.text.trim(),
        address: _addressController.text.trim(),
        bloodlines: _bloodlinesController.text.trim(),
        socialFb: _socialFbController.text.trim(),
        socialIg: _socialIgController.text.trim(),
        socialTiktok: _socialTiktokController.text.trim(),
        socialYt: _socialYtController.text.trim(),
        socialWeb: _socialWebController.text.trim(),
      );

      if (_selectedAvatar != null || _selectedCoverPhoto != null) {
        await _profileApi.uploadProfileMedia(
          mobileNumber: _mobileNumber!,
          avatar: _selectedAvatar,
          coverPhoto: _selectedCoverPhoto,
        );
      }

      // Save to local prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name);
      await prefs.setString(
        'profile_years_breeding',
        _yearsBreedingController.text.trim(),
      );
      await prefs.setString('profile_bio', _bioController.text.trim());
      await prefs.setString('profile_address', _addressController.text.trim());
      await prefs.setString(
        'profile_bloodlines',
        _bloodlinesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('💾 Profile settings saved successfully!'),
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
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
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
    _yearsBreedingController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _bloodlinesController.dispose();
    _socialFbController.dispose();
    _socialIgController.dispose();
    _socialTiktokController.dispose();
    _socialYtController.dispose();
    _socialWebController.dispose();
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
                    'Profile Settings',
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
                          // ── Profile Banner Stack (Cover & Avatar) ──
                          SizedBox(
                            height: 250,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Cover Photo
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
                                          ? Stack(
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
                                                        .withValues(alpha: 0.9),
                                                    child: const Icon(
                                                      LucideIcons.camera,
                                                      size: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
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

                                // Avatar Photo
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
                                                ? const Center(
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
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
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

                          // ── Basic Information ──
                          _buildCardWrapper(
                            title: 'Basic Information',
                            icon: LucideIcons.user,
                            children: [
                              _buildTextField(
                                label: 'Display Name',
                                controller: _nameController,
                                hint: 'e.g. John Doe',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Address / Location',
                                hint: 'e.g. San Pablo, Laguna',
                                controller: _addressController,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Years Breeding',
                                hint: 'e.g. 15 Years',
                                controller: _yearsBreedingController,
                                width: 140,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Bio & Details ──
                          _buildCardWrapper(
                            title: 'Bio & Details',
                            icon: LucideIcons.alignLeft,
                            children: [
                              _buildTextField(
                                label: 'Bio',
                                subtitle:
                                    'Tell us a bit about yourself and your background.',
                                controller: _bioController,
                                hint: 'Write your story here...',
                                maxLines: 4,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Bloodlines',
                                subtitle:
                                    'Mention the bloodlines you focus on.',
                                controller: _bloodlinesController,
                                hint: 'e.g. Kelso, Sweater, Hatch...',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Contact Links ──
                          _buildCardWrapper(
                            title: 'Social & Contact Links',
                            icon: LucideIcons.link,
                            children: [
                              _buildTextField(
                                label: 'Facebook URL',
                                hint: 'https://facebook.com/...',
                                controller: _socialFbController,
                                prefixIcon: Icons.facebook,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Instagram URL',
                                hint: 'https://instagram.com/...',
                                controller: _socialIgController,
                                prefixIcon: Icons.camera_alt_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'TikTok URL',
                                hint: 'https://tiktok.com/...',
                                controller: _socialTiktokController,
                                prefixIcon: Icons.music_note,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'YouTube URL',
                                hint: 'https://youtube.com/...',
                                controller: _socialYtController,
                                prefixIcon: Icons.play_arrow_rounded,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                label: 'Website URL',
                                hint: 'https://yourwebsite.com',
                                controller: _socialWebController,
                                prefixIcon: Icons.language,
                              ),
                            ],
                          ),

                          const SizedBox(height: 120), // Bottom padding for FAB
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saveProfileData,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(LucideIcons.save, size: 20),
                  label: const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.accentGreen),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? subtitle,
    String? hint,
    int maxLines = 1,
    double? width,
    IconData? prefixIcon,
  }) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey.shade500, size: 18)
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
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

    if (width != null) return SizedBox(width: width, child: field);
    return field;
  }
}
