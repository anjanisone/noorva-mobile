import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../../../../core/widgets/social_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.googleSignInSuccess ||
          current.status == AuthStatus.googleSignInFailure ||
          current.status == AuthStatus.appleSignInSuccess ||
          current.status == AuthStatus.appleSignInFailure,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.googleSignInSuccess:
          case AuthStatus.appleSignInSuccess:
            // Google/Apple don't give us a DOB etc., so new accounts fill in
            // the same details as email sign-up first. Clear the auth screens
            // so back can't return to them.
            final needsProfile = state.user?.dob == null;
            Navigator.pushNamedAndRemoveUntil(
              context,
              needsProfile ? AppRoutes.registerProfile : AppRoutes.permissions,
              (route) => false,
              arguments: needsProfile ? RegisterProfilePage.socialArgument : null,
            );
            break;
          case AuthStatus.googleSignInFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Google Signup failed')),
            );
            break;
          case AuthStatus.appleSignInFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Apple Signup failed')),
            );
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                CrystalCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Begin your journey with Noorva',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        NoorvaTextField(
                          label: 'Full Name',
                          hintText: 'e.g. John Doe',
                          controller: _nameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        NoorvaTextField(
                          label: 'Email',
                          hintText: 'username@example.com',
                          controller: _emailController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        NoorvaTextField(
                          label: 'Set Password',
                          hintText: 'Password',
                          controller: _passwordController,
                          isRequired: true,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        NoorvaTextField(
                          label: 'Confirm Password',
                          hintText: 'Password',
                          controller: _confirmPasswordController,
                          isRequired: true,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            onPressed: () => setState(() =>
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        NoorvaButton(
                          text: 'Next',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    AuthPendingRegisterDataSet(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                              Navigator.pushNamed(
                                  context, AppRoutes.registerProfile);
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
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
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => SocialButton(
                            label: 'Signup with Google',
                            iconPath: 'assets/images/google_icon.png',
                            isLoading: state.isGoogleLoading,
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthGoogleSignInRequested(isSignUp: true));
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => SocialButton(
                            label: 'Signup with Apple',
                            iconPath: 'assets/images/apple_icon.png',
                            isLoading: state.isAppleLoading,
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthAppleSignInRequested());
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already met Noorva? ',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, AppRoutes.login),
                              child: Text(
                                'Login',
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
      ),
    );
  }
}
