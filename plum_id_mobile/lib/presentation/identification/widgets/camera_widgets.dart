import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:plum_id_mobile/core/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  // Variables pour le Flash
  FlashMode _currentFlashMode = FlashMode.off;

  // Variables pour le Zoom
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  // Variable pour indiquer qu'une photo est en cours de chargement
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    controller
        .initialize()
        .then((_) async {
          if (!mounted) {
            return;
          }

          // Récupérer les limites de zoom de l'appareil
          _minAvailableZoom = await controller.getMinZoomLevel();
          _maxAvailableZoom = await controller.getMaxZoomLevel();

          // Initialiser le flash
          await controller.setFlashMode(_currentFlashMode);
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                print("Accès à la caméra refusé");
                break;
              default:
                print("Erreur caméra : $e");
                break;
            }
          }
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // --- Gestion du Flash ---
  Future<void> _toggleFlash() async {
    FlashMode nextMode;
    switch (_currentFlashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
    }

    await controller.setFlashMode(nextMode);
    setState(() {
      _currentFlashMode = nextMode;
    });
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight; // Mode lampe torche
    }
  }

  // --- Gestion de la mise au point (Focus au tap) ---
  void _onFocusPointTap(TapDownDetails details, BoxConstraints constraints) {
    if (!controller.value.isInitialized) return;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller.setFocusPoint(offset);
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture || !controller.value.isInitialized) return;

    setState(() {
      _isTakingPicture = true;
    });
    try {
      final image = await controller.takePicture();

      if (!mounted) return;

      // Dialog de confirmation de la photo
      final shouldSent = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Aperçu de la photo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(image.path),
                      width: 300,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Reprendre la photo
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Ferme le dialog
                          },
                          icon: const Icon(Icons.camera_alt, size: 20),
                          label: const Text("Reprendre"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Button Envoyer
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          icon: const Icon(Icons.send, size: 20),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          label: const Text("Envoyer"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldSent == true) {
        // On récupére le répertoire ou l'image sera stocker
        final directory = await getApplicationDocumentsDirectory();

        // Création du fichier
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final filePath = path.join(directory.path, 'photo_$timestamp.jpg');

        // Sauvegarde de l'image
        await File(image.path).copy(filePath);

        print("Image sauvegardé à $filePath");

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Photo sauvegardée")));
        }
      }
    } catch (e) {
      print("Erreur $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la sauvegarde de la photo")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black, // Fond noir pour éviter le flash blanc
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loader aux couleurs de votre thème
              const CircularProgressIndicator(color: AppTheme.secondaryColor),
              const SizedBox(height: 20),
              // Petit texte d'attente stylisé
              Text(
                "Démarrage de la caméra...",
                style: TextStyle(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Prendre une plume'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Bouton Flash
          IconButton(
            icon: Icon(_getFlashIcon(), color: Colors.white),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        // Pinch-to-zoom
                        onScaleStart: (details) {
                          _baseZoomLevel = _currentZoomLevel;
                        },
                        onScaleUpdate: (details) async {
                          double zoom = _baseZoomLevel * details.scale;
                          zoom = zoom.clamp(
                            _minAvailableZoom,
                            _maxAvailableZoom,
                          );
                          if (zoom != _currentZoomLevel) {
                            setState(() {
                              _currentZoomLevel = zoom;
                            });
                            await controller.setZoomLevel(zoom);
                          }
                        },
                        // Tap-to-focus
                        onTapDown:
                            (details) => _onFocusPointTap(details, constraints),
                        child: Center(child: CameraPreview(controller)),
                      );
                    },
                  ),
                ),

                // Panneau de contrôle en bas
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton aide photo
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => _showPhotoTutorial(context),
                        ),
                      ),

                      // Bouton photo
                      InkWell(
                        onTap:
                            _takePicture, // Assurez-vous que cette méthode est bien présente
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.secondaryColor,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: const BoxDecoration(
                                color: AppTheme.secondaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Indicateur de zoom
                      SizedBox(
                        width: 60,
                        child: Text(
                          "${_currentZoomLevel.toStringAsFixed(1)}x",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isTakingPicture)
            Container(
              color: Colors.black.withValues(
                alpha: 0.5,
              ), // Fond noir semi-transparent
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Capture en cours...",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoTutorial(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comment bien photographier votre plume ?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _tutorialSection(
                    icon: Icons.crop_square,
                    title: 'Fond',
                    body:
                        'Utilisez un fond uni et contrasté ( Il faut que la plume ressorte ) — '
                        'choisissez la couleur opposée à celle de la plume. '
                        'Évitez les fonds texturés (bois, tissu, herbe, gravier).',
                  ),
                  const SizedBox(height: 12),
                  _tutorialSection(
                    icon: Icons.do_not_touch,
                    title: 'Isolation',
                    body:
                        'La plume doit être seule dans le cadre. '
                        'Posez-la à plat — ne la tenez pas à la main. '
                        'Les doigts, même partiels, perturbent la détection.',
                  ),
                  const SizedBox(height: 12),
                  _tutorialSection(
                    icon: Icons.photo_size_select_large,
                    title: 'Distance et cadrage',
                    body:
                        "La plume doit occuper entre 30 % et 75 % de la surface de l'image. ",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _tutorialSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.secondaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
