import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/camera_provider.dart';
import '../../identification/widgets/camera_widgets.dart';

class HomeCameraButton extends ConsumerWidget {
  const HomeCameraButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: Material(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          onTap: () => _openCamera(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: AppTheme.textOnPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Prendre une photo",
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
