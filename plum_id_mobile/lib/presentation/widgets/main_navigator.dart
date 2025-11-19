import 'package:flutter/material.dart';
import 'package:plum_id_mobile/presentation/identification/screens/explorer_screen.dart';
import 'package:plum_id_mobile/presentation/identification/screens/home_screen.dart';
import 'package:plum_id_mobile/presentation/identification/screens/profile_screen.dart';
import 'package:plum_id_mobile/presentation/identification/screens/scanner_screen.dart';
import '../../../core/theme/app_theme.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ScannerScreen(),
    ExplorerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: "Accueil",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.image_search,
                label: "Scanner",
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.layers,
                label: "Explorer",
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: "Profil",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppTheme.navActive : AppTheme.navInactive;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
