import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dob_input.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterProfilePage extends StatefulWidget {
  /// Route argument for Google/Apple sign-up: the account already exists, so
  /// this page also asks for the name and saves the details onto it.
  static const socialArgument = 'social';

  const RegisterProfilePage({super.key});

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  String _selectedGender = 'Male';
  bool _agreedToTerms = false;
  bool _isSocial = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    _isSocial = ModalRoute.of(context)?.settings.arguments ==
        RegisterProfilePage.socialArgument;
    if (_isSocial) {
      final name = context.read<AuthBloc>().state.user?.name ?? '';
      // Skip the placeholders used when the provider gives no name.
      if (name != 'Google User' && name != 'Apple User') {
        _nameController.text = name;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  /// For social sign-up the account already exists, so leaving abandons it:
  /// sign out and go back to login.
  void _back() {
    if (!_isSocial) {
      Navigator.pop(context);
      return;
    }
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
        ),
      );
      return;
    }
    final bloc = context.read<AuthBloc>();
    if (_isSocial) {
      bloc.add(AuthProfileUpdateRequested(
        name: _nameController.text.trim(),
        email: bloc.state.user?.email ?? '',
        dob: _dobController.text,
        gender: _selectedGender,
        occupation: _occupationController.text.trim(),
      ));
    } else {
      bloc
        ..add(AuthPendingProfileDataSet(
          dob: _dobController.text,
          gender: _selectedGender,
          occupation: _occupationController.text,
        ))
        ..add(const AuthSignupRequested());
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSocial,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.verificationEmailSent ||
          current.status == AuthStatus.registerFailure ||
          current.status == AuthStatus.profileUpdateSuccess ||
          current.status == AuthStatus.profileUpdateFailure,
      listener: (context, state) {
        if (state.status == AuthStatus.profileUpdateSuccess) {
          // Social sign-up: details saved, carry on to permissions.
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.permissions, (route) => false);
        } else if (state.status == AuthStatus.profileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not save your details. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state.status == AuthStatus.verificationEmailSent) {
          // The account now exists; clear the sign-up screens from the stack.
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.verifyEmail,
            (route) => false,
            arguments: 'register',
          );
        } else if (state.status == AuthStatus.registerFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: _back,
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
              const SizedBox(height: 30),
              CrystalCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A little bit about yourself...',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name (social sign-up only; email sign-up asked already)
                      if (_isSocial) ...[
                        NoorvaTextField(
                          label: 'Full Name',
                          hintText: 'e.g. John Doe',
                          controller: _nameController,
                          isRequired: true,
                          validator: (value) => (value?.trim() ?? '').isEmpty
                              ? 'Full Name is required'
                              : null,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Date of Birth
                      NoorvaTextField(
                        label: 'What’s your date of birth?',
                        hintText: 'dd-mm-yyyy',
                        controller: _dobController,
                        isRequired: _isSocial,
                        keyboardType: TextInputType.number,
                        inputFormatters: [DobInputFormatter()],
                        validator: (value) {
                          // Required for social sign-up: it's also how we
                          // tell the profile has been completed.
                          if (_isSocial && (value?.trim() ?? '').isEmpty) {
                            return 'Date of birth is required';
                          }
                          return validateDob(value);
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          onPressed: _selectDate,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gender Selection
                      Text(
                        'How do you identify yourself?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildChoiceChip('Male'),
                            const SizedBox(width: 12),
                            _buildChoiceChip('Female'),
                            const SizedBox(width: 12),
                            _buildChoiceChip('Prefer not to say'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Occupation
                      NoorvaTextField(
                        label: 'What’s your occupation?',
                        hintText: 'Designer',
                        controller: _occupationController,
                        isRequired: false,
                      ),
                      const SizedBox(height: 24),

                      // Terms and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'terms and conditions',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Register Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state.isOtpLoading || state.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          }
                          return NoorvaButton(
                            text: _isSocial ? 'Continue' : 'Register',
                            onPressed: _submit,
                          );
                        },
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
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    bool isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color:
                isSelected ? Colors.black : Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
