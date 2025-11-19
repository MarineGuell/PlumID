import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              _buildHeader(context),
              
              // Subtitle card
              _buildSubtitleCard(),
              
              const SizedBox(height: 24),
              
              // Camera button
              _buildCameraButton(context),
              
              const SizedBox(height: 32),
              
              // Explorer section
              _buildExplorerSection(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.logoBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.eco,
              size: 50,
              color: AppTheme.logoIcon,
            ),
          ),
          const SizedBox(height: 16),
          // App title
          Text(
            "Plum'ID",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            "Identifiez les oiseaux par leurs plumes",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textOnPrimary.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        "Photographiez une plume pour identifier l'espèce d'oiseau",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: Material(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          onTap: () => {
            // TODO: Implement camera functionality
          },
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

  Widget _buildExplorerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              "Explorer",
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildExplorerCard(
                  icon: Icons.menu_book,
                  title: "Guide",
                  subtitle: "Espèces",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExplorerCard(
                  icon: Icons.map,
                  title: "Carte",
                  subtitle: "Observations",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExplorerCard(
                  icon: Icons.history,
                  title: "Historique",
                  subtitle: "Mes plumes",
                  onTap: () {
                    // TODO: Navigate to history
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExplorerCard(
                  icon: Icons.school,
                  title: "Apprendre",
                  subtitle: "Tutoriels",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      // TODO: Navigate to identification screen with image
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image sélectionnée: ${image.path}'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }
}
