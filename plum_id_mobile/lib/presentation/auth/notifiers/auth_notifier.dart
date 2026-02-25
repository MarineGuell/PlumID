import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

// État temporaire pour simuler l'authentification
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  bool build() {
    // true = connecté, false = déconnecté
    return true;
  }

  Future<void> logout() async {
    // Simuler un appel API
    await Future.delayed(const Duration(seconds: 1));
    state = false;
  }
}
