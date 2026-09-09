import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String themeKey = 'theme_mode';

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeStarted>(_onStarted);
    on<ThemeModeChanged>(_onModeChanged);

    add(const ThemeStarted());
  }

  Future<void> _onStarted(ThemeStarted event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(themeKey);
    if (themeStr != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.system,
      );
      emit(state.copyWith(themeMode: mode));
    }
  }

  Future<void> _onModeChanged(ThemeModeChanged event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(themeMode: event.mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, event.mode.toString());
  }
}
