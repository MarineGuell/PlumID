import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';
import 'package:plum_id_mobile/l10n/app_localizations.dart';

import '../../../core/providers/locale_notifier.dart';

class LanguageSelectorBottomSheet extends ConsumerWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      // Style bottom sheet (rounded top) is added by showModalBottomSheet
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              l10n.language,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          _buildLanguageOption(
            context,
            ref,
            title: 'Français',
            localeCode: 'fr',
            currentLocale: currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            title: 'English',
            localeCode: 'en',
            currentLocale: currentLocale,
          ),
          const SizedBox(height: 20), // Padding below the bottom sheet elements
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String localeCode,
    required Locale currentLocale,
  }) {
    final isSelected = currentLocale.languageCode == localeCode;

    return InkWell(
      onTap: () {
        ref.read(localeNotifierProvider.notifier).setLocale(Locale(localeCode));
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
