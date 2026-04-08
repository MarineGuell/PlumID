import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';

class ImagePreviewContainer extends StatelessWidget {
  final File? selectedImage;
  final VoidBuildContextCallback onTap;

  const ImagePreviewContainer({
    super.key,
    required this.selectedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Appuyez pour choisir une image',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

typedef VoidBuildContextCallback = void Function(BuildContext context);
