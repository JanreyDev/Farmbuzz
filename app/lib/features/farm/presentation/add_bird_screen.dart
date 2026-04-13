import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _kBgLight = Color(0xFFF5F5F5);
const Color _kBgDark = Color(0xFF121212);
const Color _kCardLight = Colors.white;
const Color _kCardDark = Color(0xFF1A1A1A);
const Color _kTopBarLight = Colors.white;
const Color _kTopBarDark = Color(0xFF161616);
const Color _kFieldLight = Color(0xFFF1F5F9);
const Color _kFieldDark = Color(0xFF222222);
const Color _kPrimary = Color(0xFF22C55E);
const Color _kAccent = Color(0xFFDCFCE7);
const Color _kBorderLight = Color(0x17000000);
const Color _kBorderDark = Color(0xFF2E2E2E);
const Color _kMutedLight = Color(0xFF6B7280);
const Color _kMutedDark = Color(0xFF9AA0A6);
const Color _kTitleLight = Color(0xFF111827);
const Color _kTitleDark = Color(0xFFF3F4F6);

const _kSampleBirdImages = [
  'https://images.pexels.com/photos/18846336/pexels-photo-18846336.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/15235677/pexels-photo-15235677.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/13607889/pexels-photo-13607889.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/19198208/pexels-photo-19198208.jpeg?auto=compress&cs=tinysrgb&w=900',
  'https://images.pexels.com/photos/13293244/pexels-photo-13293244.jpeg?auto=compress&cs=tinysrgb&w=900',
];

enum _BirdStatus { active, sick, deceased }
enum _BirdSource { bred, bought, gifted }
enum _Gender { male, female }

class AddBirdScreen extends StatefulWidget {
  const AddBirdScreen({super.key});

  @override
  State<AddBirdScreen> createState() => _AddBirdScreenState();
}

class _AddBirdScreenState extends State<AddBirdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _condition = TextEditingController();
  final _tag = TextEditingController();
  final _notes = TextEditingController();

  final List<String> _images = <String>[];
  int _previewIndex = 0;

  _Gender _gender = _Gender.male;
  _BirdStatus _status = _BirdStatus.active;
  _BirdSource _source = _BirdSource.bred;

  DateTime? _acquiredDate;
  bool _farmDetailsExpanded = false;
  bool _saving = false;
  bool _showErrors = false;

  bool get _canSave =>
      _name.text.trim().isNotEmpty &&
      _breed.text.trim().isNotEmpty &&
      !_saving;

  double get _completionProgress {
    var score = 0;
    if (_images.isNotEmpty) score++;
    if (_name.text.trim().isNotEmpty) score++;
    if (_breed.text.trim().isNotEmpty) score++;
    if (_age.text.trim().isNotEmpty || _weight.text.trim().isNotEmpty) score++;
    return score / 4;
  }

  @override
  void initState() {
    super.initState();
    _name.addListener(_refresh);
    _breed.addListener(_refresh);
    _age.addListener(_refresh);
    _weight.addListener(_refresh);
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _weight.dispose();
    _condition.dispose();
    _tag.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _kBgDark : _kBgLight;
    final topBar = isDark ? _kTopBarDark : _kTopBarLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: topBar,
        foregroundColor: isDark ? _kTitleDark : _kTitleLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Add Bird',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? _kTitleDark : _kTitleLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _canSave ? _kPrimary : (isDark ? _kMutedDark : _kMutedLight),
                    ),
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? _kBorderDark : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          autovalidateMode: _showErrors
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 120 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuidedHeader(isDark),
                const SizedBox(height: 12),
                _detailsPanel(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhotoSection(isDark),
                      _panelDivider(isDark),
                      _sectionHeading(
                        title: 'Basic Details',
                        subtitle: 'Core bird profile information',
                        icon: Icons.badge_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _name,
                        label: 'Bird Name',
                        icon: Icons.pets_outlined,
                        isDark: isDark,
                        validator: _required,
                      ),
                      const SizedBox(height: 10),
                      _field(
                        controller: _breed,
                        label: 'Breed',
                        icon: Icons.grass_outlined,
                        isDark: isDark,
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      Text('Gender', style: _subtitleStyle(isDark)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _genderPill(
                              label: 'Male',
                              icon: Icons.male,
                              selected: _gender == _Gender.male,
                              isDark: isDark,
                              onTap: () => setState(() => _gender = _Gender.male),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _genderPill(
                              label: 'Female',
                              icon: Icons.female,
                              selected: _gender == _Gender.female,
                              isDark: isDark,
                              onTap: () => setState(() => _gender = _Gender.female),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller: _age,
                              label: 'Age (months)',
                              icon: Icons.cake_outlined,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _field(
                              controller: _weight,
                              label: 'Weight (kg)',
                              icon: Icons.monitor_weight_outlined,
                              isDark: isDark,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      _panelDivider(isDark),
                      _sectionHeading(
                        title: 'Status',
                        subtitle: 'Current bird condition',
                        icon: Icons.health_and_safety_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _statusPill(
                            label: 'Active',
                            color: const Color(0xFF16A34A),
                            selected: _status == _BirdStatus.active,
                            isDark: isDark,
                            onTap: () => setState(() => _status = _BirdStatus.active),
                          ),
                          _statusPill(
                            label: 'Sick',
                            color: const Color(0xFFF59E0B),
                            selected: _status == _BirdStatus.sick,
                            isDark: isDark,
                            onTap: () => setState(() => _status = _BirdStatus.sick),
                          ),
                          _statusPill(
                            label: 'Deceased',
                            color: const Color(0xFFDC2626),
                            selected: _status == _BirdStatus.deceased,
                            isDark: isDark,
                            onTap: () => setState(() => _status = _BirdStatus.deceased),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        child: _status == _BirdStatus.sick
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: _field(
                                  controller: _condition,
                                  label: 'Condition / Notes',
                                  icon: Icons.medical_information_outlined,
                                  isDark: isDark,
                                  maxLines: 3,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _panelDivider(isDark),
                      InkWell(
                        onTap: () => setState(() => _farmDetailsExpanded = !_farmDetailsExpanded),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Farm Details (Optional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? _kTitleDark : _kTitleLight,
                                  ),
                                ),
                              ),
                              Icon(
                                _farmDetailsExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        child: _farmDetailsExpanded
                            ? Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _field(
                                    controller: _tag,
                                    label: 'Tag / ID Number',
                                    icon: Icons.confirmation_number_outlined,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 10),
                                  _dateField(isDark),
                                  const SizedBox(height: 10),
                                  DropdownButtonFormField<_BirdSource>(
                                    initialValue: _source,
                                    decoration: _inputDecoration('Source', Icons.source_outlined, isDark),
                                    dropdownColor: isDark ? _kCardDark : _kCardLight,
                                    iconEnabledColor: isDark ? _kMutedDark : _kMutedLight,
                                    style: TextStyle(color: isDark ? _kTitleDark : _kTitleLight),
                                    items: const [
                                      DropdownMenuItem(value: _BirdSource.bred, child: Text('Bred')),
                                      DropdownMenuItem(value: _BirdSource.bought, child: Text('Bought')),
                                      DropdownMenuItem(value: _BirdSource.gifted, child: Text('Gifted')),
                                    ],
                                    onChanged: (v) => setState(() => _source = v ?? _BirdSource.bred),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      _panelDivider(isDark),
                      _sectionHeading(
                        title: 'Notes',
                        subtitle: 'Extra context for this bird',
                        icon: Icons.edit_note_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _field(
                        controller: _notes,
                        label: 'Add notes...',
                        icon: Icons.notes_outlined,
                        isDark: isDark,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? _kTopBarDark : _kTopBarLight,
          border: Border(
            top: BorderSide(
              color: isDark ? _kBorderDark : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: FilledButton(
              onPressed: _canSave ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                disabledBackgroundColor: isDark ? const Color(0xFF2A2F31) : const Color(0xFFD1D5DB),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Bird', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedHeader(bool isDark) {
    final progress = _completionProgress.clamp(0, 1).toDouble();
    final progressPct = (progress * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _kCardDark : _kCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? _kBorderDark : const Color(0xFFE3E8ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : _kAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: _kPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Create Bird Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: isDark ? _kTitleDark : _kTitleLight,
                  ),
                ),
              ),
              Text(
                '$progressPct%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Complete the details below to save a clean and complete profile.',
            style: TextStyle(
              color: isDark ? _kMutedDark : _kMutedLight,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE7ECF0),
              valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsPanel({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _kCardDark : _kCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? _kBorderDark : const Color(0xFFE3E8ED)),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _panelDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: isDark ? _kBorderDark : const Color(0xFFE6EBEF),
      ),
    );
  }

  Widget _sectionHeading({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final iconBg = isDark ? const Color(0xFF1F2630) : _kAccent;
    final titleColor = isDark ? _kTitleDark : _kTitleLight;
    final subtitleColor = isDark ? _kMutedDark : _kMutedLight;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _kPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    final muted = isDark ? _kMutedDark : _kMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Photos', isDark),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF7FAF8),
              border: Border.all(color: isDark ? _kBorderDark : const Color(0xFFDDE3E8)),
            ),
            child: _images.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _kAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: _kPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photos',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? _kTitleDark : _kTitleLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('0/10 selected', style: TextStyle(color: muted)),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(_images[_previewIndex], fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _images.removeAt(_previewIndex);
                              if (_images.isEmpty) {
                                _previewIndex = 0;
                              } else if (_previewIndex >= _images.length) {
                                _previewIndex = _images.length - 1;
                              }
                            });
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.62),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _previewIndex;
                return GestureDetector(
                  onTap: () => setState(() => _previewIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 82 : 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _kPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(_images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_images.length}/10 selected',
            style: TextStyle(color: muted),
          ),
        ],
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? _kTitleDark : _kTitleLight),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(label, icon, isDark),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? _kMutedDark : _kMutedLight),
      floatingLabelStyle: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: isDark ? _kMutedDark : const Color(0xFF6B7280)),
      filled: true,
      fillColor: isDark ? _kFieldDark : _kFieldLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? _kBorderDark : const Color(0xFFE4E9ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPrimary, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.3),
      ),
    );
  }

  Widget _title(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: isDark ? _kTitleDark : _kTitleLight,
      ),
    );
  }

  TextStyle _subtitleStyle(bool isDark) {
    return TextStyle(
      fontWeight: FontWeight.w700,
      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
    );
  }

  Widget _genderPill({
    required String label,
    required IconData icon,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _kAccent : (isDark ? _kFieldDark : _kFieldLight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _kPrimary.withValues(alpha: 0.6) : (isDark ? _kBorderDark : _kBorderLight),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? const Color(0xFF166534) : null),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF166534)
                    : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill({
    required String label,
    required Color color,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: isDark ? 0.32 : 0.16) : (isDark ? _kFieldDark : _kFieldLight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.72)
                : (isDark ? _kBorderDark : const Color(0xFFDCE2E7)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected
                ? color
                : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }

  Widget _dateField(bool isDark) {
    final value = _acquiredDate == null
        ? 'Select date'
        : '${_acquiredDate!.year}-${_acquiredDate!.month.toString().padLeft(2, '0')}-${_acquiredDate!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration('Acquisition Date', Icons.calendar_today_outlined, isDark),
        child: Text(
          value,
          style: TextStyle(color: isDark ? _kTitleDark : _kTitleLight),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    return null;
  }

  Future<void> _pickImages() async {
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final picks = <String>{..._images};
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? _kCardDark : _kCardLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Photos (${picks.length}/10)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: _kSampleBirdImages.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemBuilder: (_, index) {
                          final image = _kSampleBirdImages[index];
                          final active = picks.contains(image);
                          return InkWell(
                            onTap: () {
                              setSheet(() {
                                if (active) {
                                  picks.remove(image);
                                } else if (picks.length < 10) {
                                  picks.add(image);
                                }
                              });
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(image, fit: BoxFit.cover),
                                ),
                                if (active)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _kPrimary.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check_circle, color: Colors.white),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(picks.toList()),
                        child: const Text('Done'),
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

    if (!mounted || selected == null) return;
    setState(() {
      _images
        ..clear()
        ..addAll(selected.take(10));
      _previewIndex = _images.isEmpty ? 0 : 0;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _acquiredDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() => _acquiredDate = date);
    }
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_canSave) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pop({
      'name': _name.text.trim(),
      'breed': _breed.text.trim(),
      'images': _images,
    });
  }
}
