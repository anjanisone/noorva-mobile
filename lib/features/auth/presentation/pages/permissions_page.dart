import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/permission_bottom_sheet.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _permissionSteps = [
    {
      'title': 'Display Over Other Apps',
      'description': 'To protect your rhythms, allow me to surface above your other applications. I will only step into your vision when a quiet correction is required',
      'imagePath': 'assets/images/forgot_password.png', // Reusing available wizard asset
      'actions': (BuildContext context, VoidCallback next) => [
        PermissionAction(label: 'Allow', onPressed: next, isPrimary: true),
        PermissionAction(label: 'Deny', onPressed: next),
      ],
    },
    {
      'title': 'Enable voice interaction with Wise Old Man',
      'description': 'Your voice helps me understand you better when we speak',
      'imagePath': 'assets/images/forgot_password.png',
      'actions': (BuildContext context, VoidCallback next) => [
        PermissionAction(label: 'Allow', onPressed: next, isPrimary: true),
        PermissionAction(label: 'Deny', onPressed: next),
      ],
    },
    {
      'title': 'Location permissions',
      'description': 'Your Location helps me to guide better based on your context and situation',
      'imagePath': 'assets/images/forgot_password.png',
      'actions': (BuildContext context, VoidCallback next) => [
        PermissionAction(label: 'Allow', onPressed: next, isPrimary: true),
        PermissionAction(label: 'Allow while using the app', onPressed: next),
        PermissionAction(label: 'Deny', onPressed: next),
      ],
    },
    {
      'title': 'Deliver reminders, guidance, and scheduled prompts',
      'description': 'I’ll remind you gently, at the right moments, so guidance comes when it’s most helpful.',
      'imagePath': 'assets/images/forgot_password.png',
      'actions': (BuildContext context, VoidCallback next) => [
        PermissionAction(label: 'Allow', onPressed: next, isPrimary: true),
        PermissionAction(label: 'Deny', onPressed: next),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('PermissionsPage: Starting permission sequence');
      _showNextPermission();
    });
  }

  void _showNextPermission() {
    if (_currentStep < _permissionSteps.length) {
      final step = _permissionSteps[_currentStep];
      PermissionBottomSheet.show(
        context: context,
        title: step['title'],
        description: step['description'],
        imagePath: step['imagePath'],
        actions: step['actions'](context, () {
          debugPrint('PermissionsPage: Permission ${step['title']} handled. Moving to next.');
          Navigator.pop(context); // Close bottom sheet
          setState(() {
            _currentStep++;
          });
          _showNextPermission();
        }),
      );
    } else {
      // All permissions handled, navigate to personalization
      Navigator.pushReplacementNamed(context, AppRoutes.personalization);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111113),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
