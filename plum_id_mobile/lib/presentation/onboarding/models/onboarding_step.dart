import 'package:flutter/material.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;

  OnboardingStep({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
  });
}
