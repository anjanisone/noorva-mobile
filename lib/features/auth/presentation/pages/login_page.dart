import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_mascot.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _cardTop = 150;
  static const double _mascotHeight = 150;
  // Sinks the feet slightly into the card edge so he looks planted on it.
  static const double _mascotFootOverlap = 6;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.loginSuccess ||
          current.status == AuthStatus.loginFailure ||
          current.status == AuthStatus.accountNotFound ||
          current.status == AuthStatus.emailNotVerified ||
          current.status == AuthStatus.googleSignInSuccess ||
          current.status == AuthStatus.googleSignInFailure ||
          current.status == AuthStatus.appleSignInSuccess ||
          current.status == AuthStatus.appleSignInFailure,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.loginSuccess:
          case AuthStatus.googleSignInSuccess:
          case AuthStatus.appleSignInSuccess:
            // Let the mascot finish: Thinking revers (1s) -> idle ->
            // Login Success (1s) must play before leaving the page.
            Future.delayed(const Duration(milliseconds: 2800), () {
              if (context.mounted) {
                // Clear the auth screens so back can't return to them.
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                  arguments: HomePage.welcomeArgument,
                );
              }
            });
            break;
          case AuthStatus.accountNotFound:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    state.errorMessage ?? 'No account found. Please sign up.'),
              ),
            );
            Navigator.pushNamed(context, AppRoutes.register);
            break;
          case AuthStatus.emailNotVerified:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ??
                    'Please verify your email before logging in.'),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.verifyEmail,
              (route) => false,
              arguments: 'login',
            );
            break;
          case AuthStatus.loginFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (state.errorMessage ?? '').contains('invalid-credential')
                      ? 'Incorrect email or password, or no account exists yet.'
                      : (state.errorMessage ??
                          'Login failed. Please try again.'),
                ),
                backgroundColor: Colors.redAccent,
                action: SnackBarAction(
                  label: 'Sign up',
                  textColor: Colors.white,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                ),
              ),
            );
            break;
          case AuthStatus.googleSignInFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Google Sign-In failed. Please try again.')),
            );
            break;
          case AuthStatus.appleSignInFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Apple Sign-In failed. Please try again.')),
            );
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: [
                // Main Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: _cardTop),
                        CrystalCard(
                          title: 'Welcome to Noorva',
                          titleStyle: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                NoorvaTextField(
                                  label: 'Email',
                                  hintText: 'username@example.com',
                                  isRequired: true,
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                NoorvaTextField(
                                  label: 'Password',
                                  hintText: 'Password',
                                  isRequired: true,
                                  obscureText: !_isPasswordVisible,
                                  controller: _passwordController,
                                  errorText: _passwordError,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                    ),
                                    onPressed: () => setState(() =>
                                        _isPasswordVisible =
                                            !_isPasswordVisible),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 2),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.forgotPassword);
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    if (state.isLoading) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: CircularProgressIndicator(
                                              color: Colors.white),
                                        ),
                                      );
                                    }
                                    return NoorvaButton(
                                      text: 'Login',
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _passwordError = null;
                                          });
                                          context.read<AuthBloc>().add(
                                                AuthLoginRequested(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                ),
                                              );
                                        }
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildDivider(),
                                const SizedBox(height: 16),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) => SocialButton(
                                    label: 'Sign in with Google',
                                    iconPath: 'assets/images/google_icon.png',
                                    isLoading: state.isGoogleLoading,
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                          const AuthGoogleSignInRequested());
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) => SocialButton(
                                    label: 'Sign in with Apple',
                                    iconPath: 'assets/images/apple_icon.png',
                                    isLoading: state.isAppleLoading,
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                          const AuthAppleSignInRequested());
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Haven’t met Noorva yet? ",
                                      style: GoogleFonts.outfit(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.register);
                                      },
                                      child: Text(
                                        'Start Here',
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
                      ],
                    ),
                  ),
                ),

                // Mascot drawn after the card so he stands on its top edge
                // instead of hiding behind it.
                Positioned(
                  top: MediaQuery.paddingOf(context).top +
                      _cardTop -
                      _mascotHeight +
                      _mascotFootOverlap,
                  right: 24,
                  child: const IgnorePointer(
                    child: AuthMascot(
                      height: _mascotHeight,
                      alignment: Alignment.bottomCenter,
                      fallbackAsset: 'assets/images/noorva_login.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.1),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.1),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
