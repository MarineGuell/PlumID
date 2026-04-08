import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/camera_provider.dart';
import '../../identification/widgets/camera_widgets.dart';
import '../../import/widgets/image_picker_bottom_sheet.dart';
import '../../import/screens/import_screen.dart';

class HomeActionButtons extends ConsumerWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              title: "Identifier",
              icon: Icons.camera_alt,
              onTap: () => _openCamera(context, ref),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              title: "Importer",
              icon: Icons.photo_library,
              onTap: () => _showPickerOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetCtx) {
        return ImagePickerBottomSheet(
          onPickImage: (source) => _pickImage(context, source),
          onPickFile: () => _pickFile(context),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null && context.mounted) {
        _navigateToPreview(context, File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erreur lors de la sélection : $e');
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (result != null && result.files.single.path != null && context.mounted) {
        _navigateToPreview(context, File(result.files.single.path!));
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erreur lors de la sélection : $e');
      }
    }
  }

  void _navigateToPreview(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportScreen(selectedImage: imageFile),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.secondaryColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppTheme.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppTheme.textOnPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context, WidgetRef ref) async {
    try {
      // Récupérer la caméra arrière via le provider
      final camera = await ref.read(backCameraProvider.future);

      if (!context.mounted) return;

      // Naviguer vers l'écran de caméra avec la caméra récupérée
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen(camera: camera)),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture de la caméra: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
