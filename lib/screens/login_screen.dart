import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../state/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primaryBlue = Color(0xFF1607B8);
  static const Color _fieldFill = Color(0xFFF0F0F0);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(email, password);

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 29,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.accessibility_new_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Login to continue',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _LoginTextField(
                      controller: _emailController,
                      hintText: 'Email or Phone',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    _LoginTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.forgotPassword);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryBlue,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 245,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primaryBlue.withOpacity(
                            0.55,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    const _SocialDivider(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _SocialButton.google(),
                        SizedBox(width: 18),
                        _SocialButton.facebook(),
                        SizedBox(width: 18),
                        _SocialButton.tiktok(),
                      ],
                    ),
                    SizedBox(height: constraints.maxHeight * 0.095),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 13,
                            letterSpacing: 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            Routes.register,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: _primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF444444),
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: _LoginScreenState._fieldFill,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 14,
            letterSpacing: 0,
          ),
          prefixIcon: Icon(icon, color: Colors.black, size: 22),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: _LoginScreenState._primaryBlue,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFF8E8E8E), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFF8E8E8E), thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
  });

  const _SocialButton.google()
      : icon = const _GoogleIcon();

  const _SocialButton.facebook()
      : icon = const _FacebookIcon();

  const _SocialButton.tiktok()
      : icon = const _TikTokIcon();

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 52,
      child: Material(
        color: _LoginScreenState._fieldFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Center(child: icon),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21,
      height: 21,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _TikTokIcon extends StatelessWidget {
  const _TikTokIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _TikTokGlyph(color: Color(0xFF25F4EE), offset: Offset(-1.6, 0)),
          _TikTokGlyph(color: Color(0xFFFF0050), offset: Offset(1.6, 1.2)),
          _TikTokGlyph(color: Colors.black, offset: Offset.zero),
        ],
      ),
    );
  }
}

class _TikTokGlyph extends StatelessWidget {
  const _TikTokGlyph({
    required this.color,
    required this.offset,
  });

  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: CustomPaint(
        size: const Size(20, 22),
        painter: _TikTokGlyphPainter(color),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);

    void drawArc(Color color, double start, double sweep) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, start, sweep, false, paint);
    }

    drawArc(const Color(0xFF4285F4), -0.08, 1.18);
    drawArc(const Color(0xFF34A853), 1.1, 1.28);
    drawArc(const Color(0xFFFBBC05), 2.38, 1.12);
    drawArc(const Color(0xFFEA4335), 3.5, 1.7);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.92, size.height * 0.5),
      barPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.84, size.height * 0.5),
      Offset(size.width * 0.84, size.height * 0.64),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TikTokGlyphPainter extends CustomPainter {
  const _TikTokGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stem = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.48, 0, size.width * 0.2, size.height * 0.64),
      const Radius.circular(2),
    );
    canvas.drawRRect(stem, paint);

    final flag = Path()
      ..moveTo(size.width * 0.62, 0)
      ..cubicTo(size.width * 0.76, size.height * 0.12, size.width * 0.86,
          size.height * 0.16, size.width, size.height * 0.16)
      ..lineTo(size.width, size.height * 0.34)
      ..cubicTo(size.width * 0.84, size.height * 0.34, size.width * 0.73,
          size.height * 0.27, size.width * 0.62, size.height * 0.18)
      ..close();
    canvas.drawPath(flag, paint);

    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.72),
      size.width * 0.28,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.72),
      size.width * 0.13,
      Paint()
        ..color = _LoginScreenState._fieldFill
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TikTokGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
