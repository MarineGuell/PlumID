import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:plum_id_mobile/core/constants/app_constants.dart';
import 'package:plum_id_mobile/presentation/auth/notifiers/auth_notifier.dart';
import '../../../core/theme/app_theme.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion en cours...'),
          backgroundColor: AppTheme.secondaryColor,
          duration: Duration(milliseconds: 1600),
        ),
      );
      ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {

      if (next.isLoading) return;

      if (next.hasError) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMessage = 'Erreur de connexion';
        final error = next.error;

        if (error is DioException) {
          final data = error.response?.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            final apiError = data['error'];
            errorMessage = apiError['message'] ?? errorMessage;

            if (error.response?.statusCode == 401) {
              errorMessage = 'Email ou mot de passe invalide';
            } else if (error.response?.statusCode == 404) {
              errorMessage = 'Compte introuvable';
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            // keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'votre.email@exemple.com',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Le mot de passe doit contenir au moins une majuscule';
              }
              if (!value.contains(RegExp(r'[a-z]'))) {
                return 'Le mot de passe doit contenir au moins une minuscule';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Le mot de passe doit contenir au moins un chiffre';
              }
              if (!value.contains(RegExp(r'[!@#$%^&*]'))) {
                return 'Le mot de passe doit contenir au moins un caractère spécial';
              }

              return null;
            },
          ),

          const SizedBox(height: AppConstants.smallSpacing),

          // Forgot password
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                    backgroundColor: AppTheme.secondaryColor,
                    duration: Duration(milliseconds: 1600),
                  ),
                );
              },
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.smallSpacing),

          // Login button
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
