import 'dart:async';
import 'package:flutter/material.dart';
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

/// Shown after sign-up (argument `'register'`) or when an unverified user
/// logs in (argument `'login'`). The user opens Firebase's verification link
/// from their inbox, then taps Continue here.
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  static const _resendCooldownSeconds = 60;

  Timer? _timer;
  int _cooldown = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // A link was just sent (on sign-up) or the user is coming from login;
    // either way, hold off on resends for a moment.
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isRegisterFlow =>
      ModalRoute.of(context)?.settings.arguments?.toString() != 'login';

  void _startCooldown() {
    _timer?.cancel();
    _cooldown = _resendCooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_cooldown > 0) _cooldown--;
        if (_cooldown == 0) timer.cancel();
      });
    });
  }

  /// Leaving this screen abandons verification: sign out and go to login.
  void _backToLogin() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLogin();
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.status == AuthStatus.emailVerified ||
            current.status == AuthStatus.emailVerificationPending ||
            current.status == AuthStatus.verificationEmailSent ||
            current.status == AuthStatus.verificationEmailFailure,
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.emailVerified:
              setState(() => _errorMessage = null);
              Navigator.pushNamedAndRemoveUntil(
                context,
                _isRegisterFlow ? AppRoutes.permissions : AppRoutes.home,
                (route) => false,
              );
              break;
            case AuthStatus.emailVerificationPending:
              setState(() => _errorMessage = state.errorMessage);
              break;
            case AuthStatus.verificationEmailSent:
              setState(() {
                _errorMessage = null;
                _startCooldown();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('A new verification link has been sent.'),
                  backgroundColor: Colors.green,
                ),
              );
              break;
            case AuthStatus.verificationEmailFailure:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Could not send the email.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              break;
            default:
              break;
          }
        },
        builder: (context, state) {
          final email = state.verificationEmail ?? '';

          return Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                const Positioned(
                  bottom: 0,
                  right: -20,
                  child: IgnorePointer(child: AuthMascot(height: 350)),
                ),
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
                              onTap: _backToLogin,
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
                                    'Verify your email',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    email.isNotEmpty
                                        ? 'We sent a verification link to $email. Open it, then come back and tap Continue.'
                                        : 'We sent a verification link to your email. Open it, then come back and tap Continue.',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Can’t find it? Check your spam folder.',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  if (_errorMessage != null) ...[
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
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  if (state.isLoading)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    )
                                  else
                                    NoorvaButton(
                                      text: 'I’ve verified, continue',
                                      onPressed: () => context
                                          .read<AuthBloc>()
                                          .add(const AuthEmailVerificationCheckRequested()),
                                    ),

                                  const SizedBox(height: 24),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Didn’t get the email? ',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 16,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _cooldown > 0 || state.isLoading
                                            ? null
                                            : () => context
                                                .read<AuthBloc>()
                                                .add(const AuthVerificationEmailResendRequested()),
                                        child: Text(
                                          _cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend',
                                          style: GoogleFonts.outfit(
                                            color: _cooldown > 0
                                                ? Colors.white.withValues(alpha: 0.4)
                                                : Colors.white,
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
