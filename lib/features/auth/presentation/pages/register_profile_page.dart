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
  const RegisterProfilePage({super.key});

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  String _selectedGender = 'Male';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _dobController.dispose();
    _occupationController.dispose();
    super.dispose();
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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.verificationEmailSent ||
          current.status == AuthStatus.registerFailure,
      listener: (context, state) {
        if (state.status == AuthStatus.verificationEmailSent) {
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

                      // Date of Birth
                      NoorvaTextField(
                        label: 'What’s your date of birth?',
                        hintText: 'dd-mm-yyyy',
                        controller: _dobController,
                        isRequired: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [DobInputFormatter()],
                        validator: validateDob,
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
                            text: 'Register',
                            onPressed: () {
                              if (!(_formKey.currentState?.validate() ?? true)) return;
                              if (_agreedToTerms) {
                                context.read<AuthBloc>()
                                  ..add(AuthPendingProfileDataSet(
                                    dob: _dobController.text,
                                    gender: _selectedGender,
                                    occupation: _occupationController.text,
                                  ))
                                  ..add(const AuthSignupRequested());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please agree to the terms and conditions'),
                                  ),
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
            ],
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
