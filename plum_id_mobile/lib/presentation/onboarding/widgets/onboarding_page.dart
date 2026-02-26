import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/onboarding_step.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingStep step;
  final Widget animatedIcon;

  const OnboardingPage({
    super.key,
    required this.step,
    required this.animatedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          animatedIcon,
          const SizedBox(height: 64),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textOnPrimary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
