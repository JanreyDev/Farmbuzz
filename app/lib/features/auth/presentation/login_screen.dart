import 'package:app/app/navigation/app_routes.dart';
import 'package:app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF111714) : const Color(0xFFF5F7F2);
    final titleColor = isDark ? const Color(0xFFE3F3E5) : _kDarkGreen;
    final subtitleColor = isDark ? const Color(0xFF9FB3A2) : const Color(0xFF727272);
    final dividerColor = isDark ? const Color(0xFF31463A) : const Color(0xFFDCE4DD);
    final mutedText = isDark ? const Color(0xFFA6B5AB) : const Color(0xFF777777);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Login',
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: 0.2,
                  ),
                ),
                        const SizedBox(height: 4),
                        Text(
                          'Log in to your FarmBuzz account',
                          style: TextStyle(fontSize: 16, color: subtitleColor),
                        ),
                        const SizedBox(height: 24),
                        _MobileNumberField(
                          controller: _mobileController,
                          validator: _mobileValidator,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        AuthInputField(
                          label: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscurePassword,
                          validator: _requiredField,
                          onSuffixTap: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimaryGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Log In'),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? const Color(0xFF364B40) : const Color(0xFFDBDBDB))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9A9A9A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: isDark ? const Color(0xFF364B40) : const Color(0xFFDBDBDB))),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: TextStyle(color: mutedText),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).pushNamed(AppRoutes.signup),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _mobileValidator(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^9\d{9}$').hasMatch(input)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }
}

class _MobileNumberField extends StatelessWidget {
  const _MobileNumberField({
    required this.controller,
    required this.validator,
    required this.isDark,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFB6C7BC) : const Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A231E) : const Color(0xFFEEF3EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF34453B) : const Color(0xFFD7E2D8)),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.phone_outlined,
                  size: 19,
                  color: isDark ? const Color(0xFF96AA9C) : const Color(0xFF7F8F82),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                width: 1,
                height: 20,
                color: isDark ? const Color(0xFF3C4E43) : const Color(0xFFCBD8CC),
              ),
              Text(
                '+63',
                style: TextStyle(
                  color: isDark ? const Color(0xFFB6C8BB) : const Color(0xFF556358),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: '9XX XXX XXXX',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF7F9286) : const Color(0xFF8A988D)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(0, 14, 12, 14),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
