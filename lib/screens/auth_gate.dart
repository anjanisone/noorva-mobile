import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../services/auth_service.dart';

/// Shows the home screen for signed-in users and the login screen otherwise.
class AuthGate extends StatelessWidget {
  AuthGate({super.key, AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData ? const HomePage() : const LoginPage();
      },
    );
  }
}
