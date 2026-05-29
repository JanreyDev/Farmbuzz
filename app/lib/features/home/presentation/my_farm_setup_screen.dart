import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/farm_api.dart';

class MyFarmSetupScreen extends StatefulWidget {
  final VoidCallback onCreated;

  const MyFarmSetupScreen({super.key, required this.onCreated});

  @override
  State<MyFarmSetupScreen> createState() => _MyFarmSetupScreenState();
}

class _MyFarmSetupScreenState extends State<MyFarmSetupScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  // Use a getter so hot reload updates it immediately without needing a full restart
  int get _totalSteps => 2;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final FarmApi _farmApi = FarmApi();
  bool _isCreating = false;

  // Step 1 — Name
  final _farmNameController = TextEditingController();
  final _taglineController = TextEditingController();

  // Step 2 — Location
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _farmNameController.dispose();
    _taglineController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _slideController.forward(from: 0);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _slideController.forward(from: 0);
    }
  }

  bool get _canContinue {
    if (_currentStep == 0) return _farmNameController.text.trim().isNotEmpty;
    return true;
  }

  String get _farmName =>
      _farmNameController.text.trim().isEmpty ? 'My Farm' : _farmNameController.text.trim();

  String get _location {
    final city = _cityController.text.trim();
    final province = _provinceController.text.trim();
    if (city.isEmpty && province.isEmpty) return 'Location not set';
    if (city.isEmpty) return province;
    if (province.isEmpty) return city;
    return '$city, $province';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= _totalSteps) {
      _currentStep = _totalSteps - 1;
    }
    if (_currentStep < 0) {
      _currentStep = 0;
    }

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isKeyboardOpen ? 12 : 28),

            // ── Step dots ──
            _buildStepDots(),

            SizedBox(height: isKeyboardOpen ? 12 : 28),

            // ── Main card ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: isKeyboardOpen ? 0 : 8,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isKeyboardOpen ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step label
                          Text(
                            'STEP ${_currentStep + 1} OF $_totalSteps',
                            style: TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 6 : 10),

                          // Title
                          Text(
                            _stepTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 4 : 8),

                          // Subtitle
                          Text(
                            _stepSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: isKeyboardOpen ? 12 : 24),

                          // Step content
                          Expanded(child: _buildStepContent()),

                          // Bottom nav
                          _buildBottomNav(isKeyboardOpen),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isKeyboardOpen ? 12 : 24),
          ],
        ),
      ),
    );
  }

  // ── Step dots ──────────────────────────────────────────────────────────────
  Widget _buildStepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive || isDone
                ? AppColors.accentGreen
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  // ── Step titles & subtitles ────────────────────────────────────────────────
  String get _stepTitle {
    switch (_currentStep) {
      case 0: return 'Name your farm';
      case 1: return 'Where are you located?';
      default: return '';
    }
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0: return 'This is what visitors see at the top of your page. You can change it later.';
      case 1: return 'City-level only — your exact address is never shown publicly.';
      default: return '';
    }
  }

  // ── Step body content ──────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      default: return const SizedBox();
    }
  }

  // Step 1 — Farm name & Cover Photo
  Widget _buildStep1() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildInput(
          controller: _farmNameController,
          hint: 'e.g. Dela Cruz Farm',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text(
          'Optional tagline — one short line under your name',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        _buildInput(
          controller: _taglineController,
          hint: 'What makes your farm unique?',
        ),
        const SizedBox(height: 32),
        const Text(
          'Add a cover photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A wide landscape image works best. You can skip this and add one later.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _DashRectPainter(color: Colors.grey.shade400),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.upload, size: 24, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to choose a photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, or WEBP · up to 15 MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2 — Location & Review
  Widget _buildStep2() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildInput(controller: _cityController, hint: 'City (e.g. San Pablo)', onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        _buildInput(controller: _provinceController, hint: 'Province / Region (e.g. Laguna)', onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        Text(
          'When did you start operating?',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 140,
          child: _buildInput(controller: _yearController, hint: 'Year (e.g. 2016)', keyboardType: TextInputType.number),
        ),
        const SizedBox(height: 32),
        const Text(
          'Almost done',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your farm starts as a draft — only you can see it. Once you add a story and feature your best animals, you can publish it to the community.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 16),
        // Farm preview card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.checkCircle,
                  size: 20,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _farmName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(LucideIcons.settings2, size: 13, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              'You can edit all of this any time from Settings.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  // ── Bottom nav row ─────────────────────────────────────────────────────────
  Widget _buildBottomNav(bool isKeyboardOpen) {
    final isLastStep = _currentStep == _totalSteps - 1;
    final isFirstStep = _currentStep == 0;

    return Padding(
      padding: EdgeInsets.only(top: isKeyboardOpen ? 12 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Skip (step 0) or Back
          GestureDetector(
            onTap: isFirstStep ? _goNext : _goBack,
            child: Row(
              children: [
                if (!isFirstStep)
                  Icon(LucideIcons.arrowLeft, size: 15, color: Colors.grey.shade700),
                if (!isFirstStep) const SizedBox(width: 4),
                Text(
                  isFirstStep ? 'Skip for now' : 'Back',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Right: Continue or Create my farm
          GestureDetector(
            onTap: (_canContinue || !isFirstStep) && !_isCreating ? (isLastStep ? _createFarm : _goNext) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: ((_canContinue || !isFirstStep) && !_isCreating)
                    ? AppColors.accentGreen
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLastStep && !_isCreating)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(LucideIcons.checkCircle, size: 15, color: Colors.white),
                    ),
                  if (_isCreating)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    ),
                  Text(
                    isLastStep ? (_isCreating ? 'Creating...' : 'Create my farm') : 'Continue',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ((_canContinue || !isFirstStep) && !_isCreating)
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (!isLastStep)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(LucideIcons.arrowRight, size: 15, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared text field ──────────────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Future<void> _createFarm() async {
    if (_isCreating) return;

    final name = _farmNameController.text.trim();
    final tagline = _taglineController.text.trim();
    final city = _cityController.text.trim();
    final province = _provinceController.text.trim();
    final yearStr = _yearController.text.trim();
    final year = int.tryParse(yearStr) ?? 0;

    setState(() => _isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final mobileNumber = prefs.getString('auth_mobile_number');

      if (mobileNumber != null && mobileNumber.isNotEmpty) {
        await _farmApi.createFarm(
          mobileNumber: mobileNumber,
          name: name,
          city: city.isNotEmpty ? city : (province.isNotEmpty ? province : null),
          startedYear: year > 0 ? year : null,
        );
      }

      await prefs.setString('farm_name', name);
      await prefs.setString('farm_tagline', tagline);
      await prefs.setString('farm_city', city);
      await prefs.setString('farm_province', province);
      await prefs.setInt('farm_year', year);
      await prefs.setBool('farm_created', true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isCreating = false);
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${name.isEmpty ? 'My Farm' : name} created!'),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      widget.onCreated();
    }
  }
}

class FallbackFarmStore {
  static bool farmCreated = false;
  static String farmName = '';
  static String farmTagline = '';
  static String farmCity = '';
  static String farmProvince = '';
  static int farmYear = 0;
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
