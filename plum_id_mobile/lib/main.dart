import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:plum_id_mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_notifier.dart';
import 'presentation/auth/notifiers/auth_notifier.dart';
import 'presentation/auth/screens/auth_screen.dart';
import 'presentation/widgets/main_navigator.dart';
import 'presentation/providers/providers.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    ProviderScope(
      overrides: [
        // Override the sharedPreferences provider with the pre-initialized instance
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      ],
      child: PlumIDApp(prefs: sharedPreferences),
    ),
  );
}

class PlumIDApp extends ConsumerWidget {
  final SharedPreferences prefs;

  const PlumIDApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    final locale = ref.watch(localeNotifierProvider); // Added locale watch
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: "Plum'ID",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale, // Added locale
      localizationsDelegates: const [
        // Added localizationsDelegates
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          AppLocalizations.supportedLocales, // Added supportedLocales
      home: authState.when(
        skipLoadingOnReload: true,
        data: (user) {
          if (user != null) return const MainNavigator();
          return const AuthScreen();
          // final hasSeenOnboarding =
          //     prefs.getBool('has_seen_onboarding') ?? false;
          // return hasSeenOnboarding
          //     ? const AuthScreen()
          //     : const OnboardingScreen();
        },
        error: (error, stack) => const AuthScreen(),
        loading:
            () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
      ),
      routes: {
        '/home': (context) => const MainNavigator(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}
