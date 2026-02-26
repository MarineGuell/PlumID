import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';

import '../../../domain/entities/user_profile.dart';
import '../../auth/notifiers/auth_notifier.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController(text: '********');

    // Initialiser les champs avec les données actuelles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AsyncData<UserProfile?> && authState.value != null) {
        final profile = authState.value!;
        _usernameController.text = profile.username;
        _emailController.text = profile.email;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // _toggleEdit and _saveChanges methods removed temporarily as editing is disabled

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text('Informations personnelles'),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                'Erreur : $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        data:
            (profile) =>
                profile != null
                    ? _buildContent(context, profile)
                    : const Center(child: Text("Non connecté")),
      ),
      floatingActionButton:
          authState is AsyncData
              ? FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cette fonctionnalité sera bientôt disponible',
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                backgroundColor: Colors.grey,
                icon: const Icon(Icons.edit_off, color: Colors.white),
                label: const Text(
                  'Modifier (Bientôt)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.username.isNotEmpty
                        ? profile.username
                            .substring(0, profile.username.length >= 2 ? 2 : 1)
                            .toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildInputLabel('Nom d\'utilisateur'),
            _buildTextField(
              controller: _usernameController,
              icon: Icons.person_outline,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom d\'utilisateur est requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            _buildInputLabel('Adresse e-mail'),
            _buildTextField(
              controller: _emailController,
              icon: Icons.email_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'adresse e-mail est requise';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Veuillez entrer une adresse e-mail valide';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            _buildInputLabel('Mot de passe'),
            Stack(
              children: [
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  enabled: false,
                  obscureText: true,
                ),
                if (_isEditing)
                  Positioned(
                    right: 8,
                    top: 8,
                    bottom: 8,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Modification du mot de passe à implémenter',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Changer'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.grey.shade600,
        fontWeight: enabled ? FontWeight.w500 : FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        prefixIcon: Icon(
          icon,
          color:
              enabled ? Theme.of(context).primaryColor : Colors.grey.shade400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        errorMaxLines: 2,
      ),
    );
  }
}
