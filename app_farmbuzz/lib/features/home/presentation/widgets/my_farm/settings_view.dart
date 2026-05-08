import 'package:flutter/material.dart';
import 'package:farmbuzz/core/session/app_session.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/home/data/farm_api.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmSettingsView extends StatefulWidget {
  const FarmSettingsView({
    super.key,
    required this.farmData,
    required this.onSaved,
    required this.onDeleted,
  });

  final Map<String, dynamic> farmData;
  final ValueChanged<Map<String, dynamic>> onSaved;
  final VoidCallback onDeleted;

  @override
  State<FarmSettingsView> createState() => _FarmSettingsViewState();
}

class _FarmSettingsViewState extends State<FarmSettingsView> {
  final FarmApi _farmApi = FarmApi();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _yearController;

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: (widget.farmData['name'] ?? '').toString(),
    );
    _cityController = TextEditingController(
      text: (widget.farmData['city'] ?? '').toString(),
    );
    _yearController = TextEditingController(
      text: (widget.farmData['started_year'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mobileNumber = AppSession.mobileNumber?.trim();
    if (mobileNumber == null || mobileNumber.isEmpty) {
      _showMessage('Please login again.');
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Farm name is required.');
      return;
    }

    final startedYear = int.tryParse(_yearController.text.trim());

    setState(() => _isSaving = true);
    try {
      final saved = await _farmApi.saveFarm(
        mobileNumber: mobileNumber,
        name: name,
        farmType: (widget.farmData['farm_type'] ?? '').toString(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        startedYear: startedYear,
      );

      if (!mounted) return;
      widget.onSaved(saved);
      _showMessage('Farm settings saved.');
    } on FarmApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Failed to save farm settings.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteFarm() async {
    final mobileNumber = AppSession.mobileNumber?.trim();
    if (mobileNumber == null || mobileNumber.isEmpty) {
      _showMessage('Please login again.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete farm?'),
        content: const Text(
          'This will permanently delete your farm record. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await _farmApi.deleteFarm(mobileNumber: mobileNumber);
      if (!mounted) return;
      widget.onDeleted();
    } on FarmApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Failed to delete farm.');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmType = (widget.farmData['farm_type'] ?? 'Poultry').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Farm Name'),
              _buildField(_nameController, hint: 'Enter farm name'),
              const SizedBox(height: 14),
              _buildLabel('Farm Type (locked)'),
              _buildReadOnlyField(farmType),
              const SizedBox(height: 14),
              _buildLabel('City / Province'),
              _buildField(_cityController, hint: 'Enter city or province'),
              const SizedBox(height: 14),
              _buildLabel('Started Year'),
              _buildField(
                _yearController,
                hint: 'e.g. 2024',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danger Zone',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete this farm and all associated farm records.',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _isDeleting ? null : _deleteFarm,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(_isDeleting ? 'Deleting...' : 'Delete Farm Permanently'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller, {
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.premiumGreen),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
