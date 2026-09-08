import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../../../../core/widgets/social_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              // Character Image peaking from top right
              Positioned(
                top: 40,
                right: -10,
                child: Image.asset(
                  'assets/images/noorva_login.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

              // Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      CrystalCard(
                        title: 'Welcome to Noorva',
                        padding: const EdgeInsets.all(24),
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
                              const SizedBox(height: 24),
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
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                  onPressed: () => setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
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
                              const SizedBox(height: 32),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  if (auth.isLoading) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return NoorvaButton(
                                    text: 'Login',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _passwordError = null;
                                        });
                                        final success = await auth.login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                        if (success && context.mounted) {
                                          Navigator.pushReplacementNamed(
                                              context, AppRoutes.home);
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(auth.errorMessage ?? 'Login failed. Please try again.'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                              _buildDivider(),
                              const SizedBox(height: 32),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => SocialButton(
                                  label: 'Sign in with Google',
                                  iconPath: 'assets/images/google_icon.png',
                                  isLoading: auth.isGoogleLoading,
                                  onPressed: () async {
                                    final success =
                                        await auth.signInWithGoogle();
                                    if (success && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.home);
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Google Sign-In failed. Please try again.')),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => SocialButton(
                                  label: 'Sign in with Apple',
                                  iconPath: 'assets/images/apple_icon.png',
                                  isLoading: auth.isAppleLoading,
                                  onPressed: () async {
                                    final success =
                                        await auth.signInWithApple();
                                    if (success && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.home);
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Apple Sign-In failed. Please try again.')),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Haven’t met Noorva yet? ",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(alpha: 0.6),
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
            ],
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
