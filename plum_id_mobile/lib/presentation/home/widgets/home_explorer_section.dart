import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../history/screens/history_screen.dart';
import 'home_explorer_card.dart';

class HomeExplorerSection extends StatelessWidget {
  const HomeExplorerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              "Naviguer",
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: HomeExplorerCard(
                  icon: Icons.menu_book,
                  title: "Guide",
                  subtitle: "Espèces",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeExplorerCard(
                  icon: Icons.map,
                  title: "Carte",
                  subtitle: "Observations",
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Row(
            children: [
              Expanded(
                child: HomeExplorerCard(
                  icon: Icons.history,
                  title: "Historique",
                  subtitle: "Mes plumes",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeExplorerCard(
                  icon: Icons.school,
                  title: "Apprendre",
                  subtitle: "Tutoriels",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
