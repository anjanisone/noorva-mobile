import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_mascot.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 300; // 5 minutes
  bool _isExpired = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _isExpired = false;
    _errorMessage = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isExpired = true;
          _errorMessage =
              "This verification code is no longer valid. Please request a new one to continue securely";
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  String _flow() {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args?.toString() ?? 'register';
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) {
      return "${username[0]}***@$domain";
    }
    return "${username.substring(0, 2)}***${username.substring(username.length - 1)}@$domain";
  }

  void _handleVerify() {
    if (_isExpired) return;
    if (_otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the code.';
      });
      return;
    }
    context.read<AuthBloc>().add(AuthOtpVerifyRequested(_otp, flow: _flow()));
  }

  void _handleResend() {
    final flow = _flow();
    final authBloc = context.read<AuthBloc>();
    if (flow == 'forgotPassword') {
      authBloc.add(AuthPasswordResetOtpRequested(authBloc.state.otpTargetEmail ?? ''));
    } else {
      authBloc.add(const AuthSignupOtpRequested());
    }
  }

  void _onResendSucceeded() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new 6-digit verification code has been sent.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.otpVerifiedForgotPasswordFlow ||
          current.status == AuthStatus.otpVerifiedRegisterFlow ||
          current.status == AuthStatus.otpVerificationFailure ||
          current.status == AuthStatus.registerFailure ||
          current.status == AuthStatus.signupOtpSent ||
          current.status == AuthStatus.signupOtpFailure ||
          current.status == AuthStatus.passwordResetOtpSent ||
          current.status == AuthStatus.passwordResetOtpFailure,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.otpVerifiedForgotPasswordFlow:
            setState(() => _errorMessage = null);
            Navigator.pushReplacementNamed(context, AppRoutes.resetPassword);
            break;
          case AuthStatus.otpVerifiedRegisterFlow:
            setState(() => _errorMessage = null);
            Navigator.pushReplacementNamed(context, AppRoutes.permissions);
            break;
          case AuthStatus.otpVerificationFailure:
          case AuthStatus.registerFailure:
            setState(() {
              _errorMessage = state.errorMessage ?? 'Verification failed. Please try again.';
            });
            break;
          case AuthStatus.signupOtpSent:
          case AuthStatus.passwordResetOtpSent:
            _onResendSucceeded();
            break;
          case AuthStatus.signupOtpFailure:
          case AuthStatus.passwordResetOtpFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to resend code. Please try again.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        final targetEmail = state.otpTargetEmail ?? '';
        final maskedEmail = _maskEmail(targetEmail);

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Stationary Character Image at bottom right
              const Positioned(
                bottom: 0,
                right: -20,
                child: AuthMascot(height: 350),
              ),
              // Scrollable content
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OTP Verification',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  targetEmail.isNotEmpty
                                      ? 'Enter the 6 digit code sent to $maskedEmail'
                                      : 'Enter the 6 digit code sent to your registered email address',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // OTP Input Row (6 Digits)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                      6, (index) => _buildOtpBox(index)),
                                ),

                                const SizedBox(height: 32),

                                // Error or Timer Message
                                if (_errorMessage != null)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(Icons.error_outline,
                                            color: Color(0xFFEF4444), size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFEF4444),
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else if (!_isExpired)
                                  Center(
                                    child: Text(
                                      'OTP Expires in ${_formatTime(_secondsRemaining)}',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFF8A80),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 32),

                                if (state.isOtpLoading || state.isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                                  )
                                else
                                  NoorvaButton(
                                    text: 'Verify OTP',
                                    onPressed: _isExpired ? () {} : _handleVerify,
                                  ),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Haven’t received OTP? ",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _handleResend,
                                      child: Text(
                                        'Resend OTP',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Space for keyboard when scrolled
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtpBox(int index) {
    bool hasValue = _controllers[index].text.isNotEmpty;
    bool isError = _errorMessage != null && _errorMessage!.contains("match");

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      },
      child: Container(
        width: 44, // reduced from 64 to fit 6 boxes comfortably
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF111113),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isError
                ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                : (hasValue
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1)),
            width: 1,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (value.length > 1) {
                  _controllers[index].text = value.substring(value.length - 1);
                  _controllers[index].selection = TextSelection.fromPosition(
                    const TextPosition(offset: 1),
                  );
                }

                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                  _handleVerify();
                }
              }
              setState(() {});
            },
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            cursorColor: Colors.white,
            showCursor: false,
            style: GoogleFonts.outfit(
              color: isError
                  ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                  : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: '-',
              hintStyle: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
