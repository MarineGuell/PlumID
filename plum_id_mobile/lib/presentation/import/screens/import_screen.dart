import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';
import 'package:plum_id_mobile/presentation/widgets/info_card.dart';

class ImportScreen extends StatefulWidget {
  final File selectedImage;

  const ImportScreen({super.key, required this.selectedImage});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _uploadImage() {
    // TODO: Connect this to the API for identification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identification en cours... (API à connecter)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Import d\'une image',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const InfoCard(
                  text: 'Importer une image pour identification',
                ),
                const SizedBox(height: 20),

                // Image preview
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 1.0, // Portrait aspect ratio
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: FileImage(widget.selectedImage),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Upload button
                AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30), // Match approx button borderRadius
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                spreadRadius: _glowAnimation.value * 0.5, // Ombre moins large
                                blurRadius: _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: _uploadImage,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.primaryColor,
                              side: BorderSide(
                                color: Colors.white,
                                width: _glowAnimation.value / 2, // Bordure plus visible
                                strokeAlign: BorderSide.strokeAlignInside, // Agrandissement vers l'intérieur
                              ),
                            ),
                            child: const Text(
                              'Identifier l\'oiseau',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

