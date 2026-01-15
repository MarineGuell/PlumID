import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeSubtitleCard extends StatelessWidget {
  const HomeSubtitleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        "Photographiez une plume pour identifier l'espèce d'oiseau",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }
}
