import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
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
      home: const MainNavigator(),
    );
  }
}
