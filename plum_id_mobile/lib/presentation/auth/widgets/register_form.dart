import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:plum_id_mobile/core/constants/app_constants.dart';
import 'package:plum_id_mobile/presentation/auth/notifiers/auth_notifier.dart';
import '../../../core/theme/app_theme.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _fieldErrors.clear();
    });
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription en cours...'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      ref
          .read(authNotifierProvider.notifier)
          .register(
            _emailController.text,
            _usernameController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.isLoading) return;

      if (next.hasError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMessage = "Erreur d'inscription";
        Map<String, String> newFieldErrors = {};
        final error = next.error;

        if (error is DioException) {
          final data = error.response?.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            final apiError = data['error'];
            final errorCode = apiError['code']?.toString() ?? '';
            errorMessage = apiError['message'] ?? errorMessage;

            if (apiError['details'] != null &&
                apiError['details']['errors'] != null) {
              final errors = apiError['details']['errors'] as List;
              if (errors.isNotEmpty) {
                for (var err in errors) {
                  if (err['loc'] != null && err['loc'].length > 1) {
                    final String field = err['loc'][1].toString();
                    newFieldErrors[field] =
                        err['msg']?.toString() ?? 'Erreur invalide';
                  }
                }
              }
            }

            if (errorCode == 'HTTP_409' || error.response?.statusCode == 409) {
              errorMessage = 'Email ou nom d\'utilisateur déjà utilisé';
            }
          } else if (error.response?.statusCode == 409) {
            errorMessage = 'Email ou nom d\'utilisateur déjà utilisé';
          }
        }

        if (mounted) {
          setState(() {
            _fieldErrors = newFieldErrors;
          });

          if (newFieldErrors.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Nom d\'utilisateur',
              hintText: 'toto34',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _fieldErrors['username'],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom d\'utilisateur';
              }
              if (value.length < 2) {
                return 'Le nom d\'utilisateur doit contenir au moins 2 caractères';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'votre.email@exemple.com',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: _fieldErrors['mail'] ?? _fieldErrors['email'],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
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
              prefixIcon: const Icon(Icons.lock_outline),
              errorText: _fieldErrors['password'],
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
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.largeSpacing),

          // Register button
          ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
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
                      "S'inscrire",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
          ),

          const SizedBox(height: AppConstants.middleSpacing),
          // Terms and conditions
          Text(
            "Politique de confidentialité",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
