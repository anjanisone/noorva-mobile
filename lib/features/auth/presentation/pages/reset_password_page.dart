import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _bubbleController;
  late Animation<double> _bubbleOpacity;
  late Animation<Offset> _bubbleSlide;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bubbleOpacity = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    );
    _bubbleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bubbleController.forward();
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fixed Character Image
          Positioned(
            bottom: 0,
            right: -10,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/forgot_password.png',
                height: 310,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Stationary Thought bubble - Exact cloud shape implementation
          Positioned(
            bottom: 110,
            left: 16,
            child: FadeTransition(
              opacity: _bubbleOpacity,
              child: SlideTransition(
                position: _bubbleSlide,
                child: const _ThoughtBubble(
                  text:
                      'I suggest you to use\na different\npassword that is\nnot similar to your\nold one',
                ),
              ),
            ),
          ),

          // Scrollable Content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111113),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Main card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CrystalCard(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset Password',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Set a new password to continue your\nconversations with Noorva',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 36),
                              _PasswordField(
                                label: 'New Password',
                                controller: _newPasswordController,
                                isVisible: _isNewPasswordVisible,
                                onToggle: () => setState(
                                  () => _isNewPasswordVisible =
                                      !_isNewPasswordVisible,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'Minimum 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _PasswordField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                isVisible: _isConfirmPasswordVisible,
                                onToggle: () => setState(
                                  () => _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              BlocConsumer<AuthBloc, AuthState>(
                                listenWhen: (previous, current) =>
                                    current.status == AuthStatus.resetPasswordSuccess ||
                                    current.status == AuthStatus.resetPasswordFailure,
                                listener: (context, state) {
                                  if (state.status == AuthStatus.resetPasswordSuccess) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password reset successfully! Check your email for validation.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                                  } else if (state.status == AuthStatus.resetPasswordFailure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.errorMessage ?? 'Password reset failed.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  if (state.isLoading) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return NoorvaButton(
                                    text: 'Reset Password',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              AuthResetPasswordRequested(_newPasswordController.text),
                                            );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Dynamic spacer for keyboard
                    SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return NoorvaTextField(
      label: label,
      hintText: 'Password',
      controller: controller,
      obscureText: !isVisible,
      isRequired: true,
      validator: validator,
      suffixIcon: GestureDetector( 
        onTap: onToggle,
        child: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white.withValues(alpha: 0.4),
          size: 22,
        ),
      ),
    );
  }
}

class _ThoughtBubble extends StatelessWidget {
  final String text;

  const _ThoughtBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              painter: _ThoughtBubblePainter(),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 200, minHeight: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            // Trailing dots to the right
            Positioned(
              right: -30,
              top: 30,
              child: _dot(12),
            ),
            Positioned(
              right: -55,
              top: 20,
              child: _dot(8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dot(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DotPainter(),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);

    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2, fill);
    canvas.drawCircle(c, size.width / 2, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThoughtBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);

    final cx = size.width / 2;
    final cy = size.height / 2;

    final humps = [
      Offset(cx - 40, cy - 45),
      Offset(cx, cy - 50),
      Offset(cx + 40, cy - 45),
      Offset(cx + 70, cy - 20),
      Offset(cx + 75, cy + 15),
      Offset(cx + 50, cy + 45),
      Offset(cx, cy + 50),
      Offset(cx - 50, cy + 45),
      Offset(cx - 75, cy + 15),
      Offset(cx - 70, cy - 20),
    ];

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy),
            width: size.width - 40,
            height: size.height - 40),
        const Radius.circular(30),
      ));

    for (final h in humps) {
      path = Path.combine(PathOperation.union, path,
          Path()..addOval(Rect.fromCircle(center: h, radius: 35)));
    }

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
