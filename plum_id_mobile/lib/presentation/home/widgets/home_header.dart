import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.largeSpacing),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.logoBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/plum_id_logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          // App title
          Text(
            "Plum'ID",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          // Subtitle
          Text(
            "Identifiez les oiseaux par leurs plumes",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textOnPrimary.withValues(alpha: 0.9),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
