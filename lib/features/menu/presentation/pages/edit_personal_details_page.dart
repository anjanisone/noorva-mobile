import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/noorva_button.dart';
import '../../../../core/widgets/noorva_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'profile_page.dart'; // To access UserProfileState fallback

class EditPersonalDetailsPage extends StatefulWidget {
  const EditPersonalDetailsPage({super.key});

  @override
  State<EditPersonalDetailsPage> createState() => _EditPersonalDetailsPageState();
}

class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  late final TextEditingController _occupationController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _nameController = TextEditingController(text: user?.name ?? UserProfileState.name);
    _emailController = TextEditingController(text: user?.email ?? UserProfileState.email);
    _dobController = TextEditingController(text: user?.dob ?? UserProfileState.dob);
    _occupationController = TextEditingController(text: user?.occupation ?? UserProfileState.occupation);
    _selectedGender = user?.gender ?? UserProfileState.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthProfileUpdateRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            dob: _dobController.text.trim(),
            gender: _selectedGender,
            occupation: _occupationController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayInitials = UserProfileState.initials;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.profileUpdateSuccess ||
          current.status == AuthStatus.profileUpdateFailure,
      listener: (context, state) {
        if (state.status == AuthStatus.profileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E1E22),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Text(
                'Profile details updated successfully.',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context);
        } else if (state.status == AuthStatus.profileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Text(
                state.errorMessage ?? 'Failed to update profile details.',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Edit Personal Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Equal balancing spacer
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Avatar Area
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayInitials,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/edit.png',
                        width: 20,
                        height: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      NoorvaTextField(
                        label: 'Full Name',
                        hintText: 'Full Name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email*
                      NoorvaTextField(
                        label: 'Email',
                        hintText: 'Email',
                        isRequired: true,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth
                      NoorvaTextField(
                        label: 'What’s your date of birth?',
                        hintText: 'dd-mm-yyyy',
                        controller: _dobController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          onPressed: _selectDate,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gender Label
                      Text(
                        'How do you identify yourself?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Gender Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
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
                      const SizedBox(height: 20),

                      // Occupation
                      NoorvaTextField(
                        label: 'What’s your occupation?',
                        hintText: 'Designer',
                        controller: _occupationController,
                      ),
                      const SizedBox(height: 40),

                      // Save Changes Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return NoorvaButton(
                            text: state.isLoading ? 'Saving...' : 'Save Changes',
                            onPressed: state.isLoading ? () {} : _saveChanges,
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
