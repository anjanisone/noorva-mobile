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
import '../widgets/auth_mascot.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          false, // Prevents the image from being pushed up by the keyboard
      body: Stack(
        children: [
          // Stationary Character Image at bottom right
          const Positioned(
            bottom: 0,
            right: -20,
            child: IgnorePointer(
              child: AuthMascot(
                height: 300,
                alignment: Alignment.bottomRight,
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
                    // Custom Back Button
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

                    // Main Card
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
                                'Forgot Password?',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter your registered email address to reset password',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 40),
                              NoorvaTextField(
                                label: 'Email',
                                hintText: 'username@gmail.com',
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              BlocConsumer<AuthBloc, AuthState>(
                                listenWhen: (previous, current) =>
                                    current.status ==
                                        AuthStatus.passwordResetOtpSent ||
                                    current.status ==
                                        AuthStatus.passwordResetOtpFailure,
                                listener: (context, state) {
                                  if (state.status ==
                                      AuthStatus.passwordResetOtpSent) {
                                    FocusScope.of(context).unfocus();
                                    // Let the mascot finish: Thinking revers (1s) ->
                                    // idle -> success (1s) must play before leaving.
                                    Future.delayed(
                                        const Duration(milliseconds: 2800), () {
                                      if (context.mounted) {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.otpVerification,
                                          arguments: 'forgotPassword',
                                        );
                                      }
                                    });
                                  } else if (state.status ==
                                      AuthStatus.passwordResetOtpFailure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.errorMessage ??
                                            'Failed to send reset code.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  if (state.isOtpLoading || state.isLoading) {
                                    return const Center(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      ),
                                    );
                                  }
                                  return NoorvaButton(
                                    text: 'Get OTP',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              AuthPasswordResetOtpRequested(
                                                  _emailController.text),
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
                    // Space for keyboard when scrolled
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
