import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';

import '../../../domain/entities/user_profile.dart';
import '../notifiers/profile_notifier.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  bool _isEditing = false;
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
      final profileState = ref.read(profileNotifierProvider);
      if (profileState is AsyncData<UserProfile>) {
        final profile = profileState.value;
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Annuler l'édition : remettre les anciennes valeurs
        final profileState = ref.read(profileNotifierProvider);
        if (profileState is AsyncData<UserProfile>) {
          final profile = profileState.value;
          _usernameController.text = profile.username;
          _emailController.text = profile.email;
        }
      }
    });
  }

  Future<void> _saveChanges(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = UserProfile(
      id: currentProfile.id,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );

    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations mises à jour avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
        title: const Text('Informations personnelles'),
        actions: [
          if (profileState is AsyncData)
            TextButton.icon(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: _isEditing ? Colors.red : Theme.of(context).primaryColor,
              ),
              label: Text(
                _isEditing ? 'Annuler' : 'Modifier',
                style: TextStyle(
                  color:
                      _isEditing ? Colors.red : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                'Erreur : $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        data: (profile) => _buildContent(context, profile),
      ),
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

            const SizedBox(height: 48),

            // Save button
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _saveChanges(profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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
