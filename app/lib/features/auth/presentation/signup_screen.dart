import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamed(AppRoutes.subscription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF232323)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Step 1 of 4',
          style: TextStyle(
            color: Color(0xFF4B4B4B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: _ProgressHeader(),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Personal Information',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2230),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tell us who you are',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF767676),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthInputField(
                        label: 'First Name',
                        hintText: 'Juan',
                        prefixIcon: Icons.person_outline,
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      AuthInputField(
                        label: 'Middle Name',
                        hintText: 'Dela',
                        prefixIcon: Icons.person_outline,
                        controller: _middleNameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AuthInputField(
                        label: 'Last Name',
                        hintText: 'Cruz',
                        prefixIcon: Icons.person_outline,
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      AuthInputField(
                        label: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icons.mail_outline,
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),
                      AuthInputField(
                        label: 'Mobile Number',
                        hintText: '+63 9XX XXX XXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _mobileController,
                        textInputAction: TextInputAction.next,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      AuthInputField(
                        label: 'Password',
                        hintText: 'Min. 8 characters',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        validator: _passwordValidator,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'At least 8 characters with a number',
                        style: TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE3E3E3))),
              ),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGoldAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue'),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 19),
                  ],
                ),
              ),
            ),
          ],
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

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final input = value.trim();
    if (!input.contains('@') || !input.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final hasMinLength = value.length >= 8;
    final hasNumber = RegExp(r'\d').hasMatch(value);
    if (!hasMinLength || !hasNumber) {
      return 'Use 8+ chars with at least one number';
    }
    return null;
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: kGoldAccent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 3),
        Expanded(
          flex: 3,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}
