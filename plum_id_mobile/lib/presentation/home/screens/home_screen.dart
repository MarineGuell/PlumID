import 'package:flutter/material.dart';
import 'package:plum_id_mobile/core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../../widgets/info_card.dart';
import '../widgets/home_camera_button.dart';
import '../widgets/home_explorer_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              const HomeHeader(),

              // Subtitle card
              const InfoCard(text: "Photographiez une plume pour identifier l'espèce d'oiseau"),

              const SizedBox(height: AppConstants.largeSpacing),

              // Action buttons
              const HomeActionButtons(),

              const SizedBox(height: AppConstants.largeSpacing),

              // Explorer section
              const HomeExplorerSection(),

              const SizedBox(height: AppConstants.mediumSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
