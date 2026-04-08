import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Future<void> Function(ImageSource) onPickImage;
  final Future<void> Function() onPickFile;

  const ImagePickerBottomSheet({
    super.key,
    required this.onPickImage,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(
              'Sélectionner une image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Depuis la galerie'),
            onTap: () {
              Navigator.of(context).pop();
              onPickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Depuis les fichiers'),
            onTap: () {
              Navigator.of(context).pop();
              onPickFile();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
