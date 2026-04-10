import 'package:app/features/auth/presentation/widgets/custom_button.dart';
import 'package:app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.onRegister,
  });

  final Future<void> Function({
    required String fullName,
    required String farmName,
    required String mobile,
    required String password,
    String? referralCode,
  }) onRegister;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _mobileController = TextEditingController(text: '+63');
  final _passwordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _farmNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  String? _validateMobile(String? value) {
    final input = (value ?? '').trim();
    final regex = RegExp(r'^\+63\d{10}$');
    if (input.isEmpty) return 'Mobile number is required';
    if (!regex.hasMatch(input)) {
      return 'Enter a valid mobile number in +63 format';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.onRegister(
        fullName: _fullNameController.text.trim(),
        farmName: _farmNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        referralCode: _referralCodeController.text.trim().isEmpty
            ? null
            : _referralCodeController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your account',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your farmer profile and verify your number.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: _fullNameController,
            label: 'Full Name',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Full name is required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _farmNameController,
            label: 'Farm Name',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Farm name is required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _mobileController,
            label: 'Mobile Number',
            hintText: '+639123456789',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: _validateMobile,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
            ],
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _referralCodeController,
            label: 'Referral Code (Optional)',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 18),
          AuthCustomButton(
            label: 'Create Account',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          Text(
            'By creating an account, you agree to FarmBuzz terms and privacy policy.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
