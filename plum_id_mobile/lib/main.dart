import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/screens/auth_screen.dart';
import 'presentation/widgets/main_navigator.dart';

void main() {
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: PlumIDApp(),
    ),
  );
}

class PlumIDApp extends StatelessWidget {
  const PlumIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Plum'ID",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // TODO: Add authentication state management
      // For now, show auth screen. Later, check if user is logged in
      home: const AuthScreen(),
      routes: {
        '/home': (context) => const MainNavigator(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}
