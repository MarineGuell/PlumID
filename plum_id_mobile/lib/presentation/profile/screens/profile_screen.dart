import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../notifiers/profile_notifier.dart';
import '../widgets/profile_menu_item.dart';
import 'placeholder_screen.dart';

// Provider pour récupérer la version de l'application
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final versionState = ref.watch(appVersionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              () => ref.read(profileNotifierProvider.notifier).refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Section Informations Utilisateur
                  profileState.when(
                    data:
                        (profile) => _buildUserInfoSection(
                          context,
                          firstName: profile.firstName,
                          lastName: profile.lastName,
                          email: profile.email,
                        ),
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    error:
                        (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Erreur de chargement: ${error.toString()}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Section Navigation
                  const Text(
                    'Général',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          onTap:
                              () => _navigateToPlaceholder(
                                context,
                                'Informations personnelles',
                              ),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.language,
                          title: 'Langue',
                          onTap:
                              () => _navigateToPlaceholder(context, 'Langue'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Support & À propos
                  const Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.star_outline,
                          title: 'Notez nous',
                          onTap:
                              () =>
                                  _navigateToPlaceholder(context, 'Notez nous'),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Politique de confidentialité',
                          onTap:
                              () => _navigateToPlaceholder(
                                context,
                                'Politique de confidentialité',
                              ),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Conditions d\'utilisation',
                          onTap:
                              () => _navigateToPlaceholder(
                                context,
                                'Conditions d\'utilisation',
                              ),
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          onTap:
                              () => _navigateToPlaceholder(context, 'Feedback'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section Actions Destructrices
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          isDestructive: true,
                          onTap: () {
                            // TODO: Implémenter la déconnexion
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Déconnexion à implémenter'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        ProfileMenuItem(
                          icon: Icons.delete_outline,
                          title: 'Supprimer le compte',
                          isDestructive: true,
                          onTap: () {
                            // TODO: Implémenter la suppression du compte
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Suppression du compte à implémenter',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Version de l'application
                  Center(
                    child: versionState.when(
                      data:
                          (version) => Text(
                            'Version $version',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      loading:
                          () => const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      error:
                          (_, __) => Text(
                            'Version introuvable',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PlaceholderScreen(title: title)),
    );
  }
}
