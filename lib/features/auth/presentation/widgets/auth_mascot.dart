import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/noorva_mascot.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Mascot for auth screens that reacts to [AuthBloc] changes made while the
/// page is open: thinking while loading, success/failed on the result.
class AuthMascot extends StatefulWidget {
  const AuthMascot({
    super.key,
    required this.height,
    this.fallbackAsset = 'assets/images/forgot_password.png',
    this.alignment = Alignment.center,
  });

  final double height;
  final String fallbackAsset;
  final Alignment alignment;

  @override
  State<AuthMascot> createState() => _AuthMascotState();
}

class _AuthMascotState extends State<AuthMascot> {
  MascotMood _mood = MascotMood.idle;
  Timer? _resetTimer;

  MascotMood _moodFor(AuthState state) {
    if (state.isLoading ||
        state.isOtpLoading ||
        state.isGoogleLoading ||
        state.isAppleLoading) {
      return MascotMood.thinking;
    }
    final status = state.status.name;
    if (status.endsWith('Failure')) return MascotMood.failed;
    if (status.endsWith('Success') ||
        status.endsWith('OtpSent') ||
        status.startsWith('otpVerified')) {
      return MascotMood.success;
    }
    return MascotMood.idle;
  }

  void _onState(BuildContext context, AuthState state) {
    final mood = _moodFor(state);
    _resetTimer?.cancel();
    // Let a failure play, then settle back so the user can retry calmly.
    // Coming from thinking, the .riv routes Thinking revers -> idle before
    // Login Failed (1s) and Failed loop (2s), so ~5s is needed to see both.
    if (mood == MascotMood.failed) {
      _resetTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _mood = MascotMood.idle);
      });
    }
    if (mood != _mood) setState(() => _mood = mood);
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _onState,
      child: NoorvaMascot(
        mood: _mood,
        // Entry loop while the user types into any auth field.
        reactToTyping: true,
        height: widget.height,
        alignment: widget.alignment,
        fallbackAsset: widget.fallbackAsset,
      ),
    );
  }
}
