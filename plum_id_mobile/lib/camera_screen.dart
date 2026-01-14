import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.max);
    controller
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                print("Accès à la caméra refusé");
                break;
              default:
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

  Future<void> _takePicture() async {
    try {
      final image = await controller.takePicture();

      if (!mounted) return;

      // Dialog de confirmation de la photo
      final shouldSent = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reprendre la photo
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Ferme le dialog
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Reprendre"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      // Button Envoyer
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text("Envoyer"),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Caméra')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 550, width: 500, child: CameraPreview(controller)),
            const SizedBox(height: 10),
            IconButton(
              constraints: const BoxConstraints(minWidth: 80, minHeight: 80),
              onPressed: _takePicture,
              icon: Image.asset(
                'assets/icons/plum_camera.png',
                width: 150,
                height: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
