import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/events/presentation/bloc/events_bloc.dart';
import 'features/goals/presentation/bloc/goals_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: _webFirebaseOptions);
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  final authRepository = AuthRepositoryImpl();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => AuthBloc(authRepository)),
        BlocProvider(create: (_) => EventsBloc()),
        BlocProvider(create: (_) => GoalsBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Web has no google-services.json. These values are the public client
/// config already committed in android/app/google-services.json.
const FirebaseOptions _webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCTsvhwz07EtUP4uChzZ8hjnUgwOUcAmlI',
  appId: '1:875117978323:android:ad1222882bb72c4f482a26',
  messagingSenderId: '875117978323',
  projectId: 'noorva-companion-mlp',
  storageBucket: 'noorva-companion-mlp.firebasestorage.app',
  authDomain: 'noorva-companion-mlp.firebaseapp.com',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Noorva App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
