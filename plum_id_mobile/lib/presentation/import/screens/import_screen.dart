import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';
import 'package:plum_id_mobile/presentation/import/widgets/image_picker_bottom_sheet.dart';
import 'package:plum_id_mobile/presentation/widgets/info_card.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection : $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      // On utilise FileType.custom pour forcer l'ouverture de l'explorateur de fichiers natif (Files)
      // plutôt que la galerie photo (ce que FileType.image fait par défaut sur certains OS).
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection : $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return ImagePickerBottomSheet(
          onPickImage: _pickImage,
          onPickFile: _pickFile,
        );
      },
    );
  }

  void _uploadImage() {
    if (_selectedImage == null) return;

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
        iconTheme: const IconThemeData(color: Colors.black),
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
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Icon(
                            Icons.insert_photo_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 10),

                // Upload button (visible only when an image is selected)
                if (_selectedImage != null)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPickerOptions(context),
        label: const Text('Importer une photo'),
        icon: const Icon(Icons.add_photo_alternate),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

