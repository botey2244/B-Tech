import 'package:flutter/material.dart';

import '../app/routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color _primaryBlue = Color(0xFF1607B8);
  static const Color _fieldFill = Color(0xFFF0F0F0);
  static const Color _successGreen = Color(0xFF43A857);

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUpperAndLower {
    final password = _passwordController.text;
    return RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password);
  }

  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasSpecialCharacter {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]')
        .hasMatch(_passwordController.text);
  }

  void _resetPassword() {
    if (!_hasMinLength ||
        !_hasUpperAndLower ||
        !_hasNumber ||
        !_hasSpecialCharacter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all password requirements.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successfully.')),
    );
    Navigator.pushReplacementNamed(context, Routes.passwordUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShortScreen = constraints.maxHeight < 740;
            final horizontalPadding = constraints.maxWidth < 360 ? 24.0 : 55.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * (isShortScreen ? 0.025 : 0.075),
                    ),
                    const Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Please enter your new password and confirm it below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: isShortScreen ? 22 : 34),
                    _ResetPasswordField(
                      controller: _passwordController,
                      hintText: 'Enter new password',
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    SizedBox(height: isShortScreen ? 12 : 18),
                    _ResetPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm new password',
                      obscureText: _obscureConfirmPassword,
                      onChanged: (_) => setState(() {}),
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    SizedBox(height: isShortScreen ? 12 : 18),
                    _RequirementRow(
                      label: 'At least 8 characters',
                      met: _hasMinLength,
                    ),
                    const SizedBox(height: 12),
                    _RequirementRow(
                      label: 'Include uppercase and lowercase letters',
                      met: _hasUpperAndLower,
                    ),
                    const SizedBox(height: 12),
                    _RequirementRow(
                      label: 'Include a number',
                      met: _hasNumber,
                    ),
                    const SizedBox(height: 12),
                    _RequirementRow(
                      label: 'Include a special character',
                      met: _hasSpecialCharacter,
                    ),
                    SizedBox(height: isShortScreen ? 22 : 34),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * (isShortScreen ? 0.03 : 0.09),
                    ),
                    const _PasswordTipBox(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResetPasswordField extends StatelessWidget {
  const _ResetPasswordField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          color: Color(0xFF444444),
          fontSize: 14,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: _ResetPasswordScreenState._fieldFill,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 14,
            letterSpacing: 0,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.black,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.black,
              size: 21,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _ResetPasswordScreenState._primaryBlue,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.met,
  });

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: met
                ? _ResetPasswordScreenState._successGreen
                : const Color(0xFFD2D2D2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordTipBox extends StatelessWidget {
  const _PasswordTipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEFF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              color: Color(0xFFD8CCFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: _ResetPasswordScreenState._primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Make sure your new password is something\nyou don't use on other websites.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                height: 1.15,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
