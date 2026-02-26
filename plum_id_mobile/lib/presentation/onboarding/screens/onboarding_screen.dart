import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plum_id_mobile/core/theme/app_theme.dart';
import 'package:plum_id_mobile/presentation/auth/screens/auth_screen.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  late AnimationController _cameraAnimationController;
  late Animation<double> _cameraAnimation;

  late AnimationController _bookAnimationController;
  late Animation<double> _bookAnimation;

  late AnimationController _mapAnimationController;
  late Animation<double> _mapAnimation;

  // Liste des étapes de l'onboarding
  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Bienvenue sur PlumID',
      description:
          'L\'application d\'identification de plumes propulsée par l\'IA.',
      imagePath: 'assets/icons/plum_camera.png',
    ),
    OnboardingStep(
      title: 'Identifiez les Plumes',
      description:
          'Prenez en photo une plume trouvée dans la nature et laissez notre IA identifier l\'espèce correspondante.',
      icon: Icons.camera_alt_outlined,
    ),
    OnboardingStep(
      title: 'Découvrez les Oiseaux',
      description:
          'Accédez à des fiches détaillées pour en apprendre plus sur les oiseaux de votre région.',
      icon: Icons.menu_book_outlined,
    ),
    OnboardingStep(
      title: 'Créez votre Collection',
      description:
          'Sauvegardez vos découvertes, suivez vos statistiques et contribuez à la cartographie des espèces.',
      icon: Icons.map_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _cameraAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _cameraAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _bookAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Rotation pour simuler une page qui se tourne légèrement
    _bookAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _bookAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Mouvement d'ondulation (flottement) pour la carte
    _mapAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _mapAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraAnimationController.dispose();
    _bookAnimationController.dispose();
    _mapAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Sauvegarder que l'onboarding est terminé
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  Widget _buildAnimatedIcon(OnboardingStep step) {
    if (step.imagePath != null) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: Container(
              width: 250,
              height: 250,
              alignment: Alignment.center,
              child: Image.asset(step.imagePath!, fit: BoxFit.fill),
            ),
          );
        },
      );
    } else if (step.icon == Icons.camera_alt_outlined) {
      return AnimatedBuilder(
        animation: _cameraAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _cameraAnimation.value,
            child: _buildCircleIcon(step.icon!),
          );
        },
      );
    } else if (step.icon == Icons.menu_book_outlined) {
      return AnimatedBuilder(
        animation: _bookAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _bookAnimation.value,
            child: _buildCircleIcon(step.icon!),
          );
        },
      );
    } else if (step.icon == Icons.map_outlined) {
      return AnimatedBuilder(
        animation: _mapAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _mapAnimation.value),
            child: _buildCircleIcon(step.icon!),
          );
        },
      );
    } else {
      return _buildCircleIcon(step.icon ?? Icons.error);
    }
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.logoBackground, // Vert d'eau
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 80,
        color: AppTheme.logoIcon, // Blanc
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Fond vert canard (primary)
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" en haut à droite
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Passer',
                  style: TextStyle(
                    color: AppTheme.surfaceColor.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Contenu glissant (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return OnboardingPage(
                    step: step,
                    animatedIcon: _buildAnimatedIcon(step),
                  );
                },
              ),
            ),

            // Section du bas (Indicateurs + Bouton)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Les petits points (dots)
                  Row(
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? AppTheme
                                      .accentColor // Orange PlumID
                                  : AppTheme.secondaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Bouton Suivant / Commencer
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentColor, // Orange pour contraster
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentPage == _steps.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
