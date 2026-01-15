import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plum_id_mobile/core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),

                // Logo
                _buildLogo(),

                const SizedBox(height: AppConstants.largeSpacing),

                // Auth Form Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        _isLogin ? 'Connexion' : 'Inscription',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      Text(
                        _isLogin
                            ? 'Connectez-vous pour accéder à votre compte'
                            : 'Créez un compte pour commencer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.mediumSpacing),

                      // Form
                      _isLogin ? const LoginForm() : const RegisterForm(),

                      const SizedBox(height: AppConstants.mediumSpacing),

                      // Toggle button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? "Pas encore de compte ?"
                                : "Déjà un compte ?",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _toggleAuthMode,
                            child: Text(
                              _isLogin ? "S'inscrire" : "Se connecter",
                              style: const TextStyle(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Lottie.asset(
          'assets/lotties/happy_bird.json',
          fit: BoxFit.contain,
          width: 150,
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ],
    );
  }
}
