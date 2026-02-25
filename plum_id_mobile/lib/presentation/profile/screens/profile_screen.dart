import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plum_id_mobile/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';
import 'package:plum_id_mobile/core/constants/app_constants.dart';

import '../notifiers/profile_notifier.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/language_selector_bottom_sheet.dart';
import '../../auth/notifiers/auth_notifier.dart';
import 'personal_info_screen.dart';

// Provider pour récupérer la version de l'application
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final versionState = ref.watch(appVersionProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: AppTheme.backgroundColor,
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
                  authState.when(
                    data:
                        (profile) =>
                            profile != null
                                ? _buildUserInfoSection(
                                  context,
                                  username: profile.username,
                                  email: profile.email,
                                )
                                : const Center(
                                  child: Text('Utilisateur non connecté'),
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const PersonalInfoScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppTheme.dividerColor,
                        ),
                        ProfileMenuItem(
                          icon: Icons.language,
                          title: l10n.language,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder:
                                  (context) =>
                                      const LanguageSelectorBottomSheet(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Support & À propos
                  Text(
                    l10n.about,
                    style: const TextStyle(
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
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.star_outline,
                          title: l10n.rateUs,
                          onTap: () async {
                            final inAppReview = InAppReview.instance;
                            if (await inAppReview.isAvailable()) {
                              inAppReview.requestReview();
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppTheme.dividerColor,
                        ),
                        ProfileMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          onTap: () async {
                            final url = Uri.parse(
                              AppConstants.privacyPolicyUrl,
                            );
                            if (await canLaunchUrl(url)) {
                              try {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } catch (e) {
                                debugPrint('Could not launch url: $e');
                              }
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppTheme.dividerColor,
                        ),
                        ProfileMenuItem(
                          icon: Icons.description_outlined,
                          title: l10n.termsOfUse,
                          onTap: () async {
                            final url = Uri.parse(AppConstants.termsOfUseUrl);
                            if (await canLaunchUrl(url)) {
                              try {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              } catch (e) {
                                debugPrint('Could not launch url: $e');
                              }
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppTheme.dividerColor,
                        ),
                        ProfileMenuItem(
                          icon: Icons.feedback_outlined,
                          title: l10n.feedback,
                          onTap: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: AppConstants.contactEmail,
                              queryParameters: {
                                'subject': 'Feedback - ${AppConstants.appName}',
                                // 'body': 'Bonjour l\'équipe PlumID,\n\n', // Optionnel
                              },
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              try {
                                await launchUrl(emailLaunchUri);
                              } catch (e) {
                                debugPrint('Could not launch email: $e');
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Impossible d\'ouvrir l\'application Mail.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
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
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.logout,
                          title: l10n.logout,
                          isDestructive: true,
                          onTap: () => _showLogoutDialog(context, ref),
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: AppTheme.dividerColor,
                        ),
                        ProfileMenuItem(
                          icon: Icons.delete_outline,
                          title: l10n.deleteAccount,
                          isDestructive: true,
                          onTap: () {
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
                            '${l10n.version} $version',
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
    required String username,
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
                username.isNotEmpty
                    ? username
                        .substring(0, username.length >= 2 ? 2 : 1)
                        .toUpperCase()
                    : 'U',
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
                  username,
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

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (bottomSheetContext) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.logoutConfirmationTitle,
                    style: Theme.of(bottomSheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(
                    l10n.logoutConfirmationMessage,
                    style: Theme.of(bottomSheetContext).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallSpacing),
                  TextButton(
                    onPressed:
                        () => Navigator.of(bottomSheetContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (shouldLogout == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  // _showDeleteAccountDialog method removed because it's disabled for now
}
