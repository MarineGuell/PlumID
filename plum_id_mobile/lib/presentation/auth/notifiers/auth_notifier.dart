import 'package:plum_id_mobile/domain/entities/user_profile.dart';
import 'package:plum_id_mobile/domain/usecases/auth_usecases_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserProfile?> build() async {
    return _checkAuthStatus();
  }

  Future<UserProfile?> _checkAuthStatus() async {
    final getMeUseCase = ref.read(getMeUseCaseProvider.future);
    try {
      final user = await (await getMeUseCase).execute();
      return user;
    } catch (e) {
      // If fetching user fails (e.g., token expired or no token), return null (unauthenticated)
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading<UserProfile?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final loginUseCase = await ref.read(loginUseCaseProvider.future);
      return await loginUseCase.execute(email, password);
    });
  }

  Future<void> register(String email, String username, String password) async {
    state = const AsyncLoading<UserProfile?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final registerUseCase = await ref.read(registerUseCaseProvider.future);
      await registerUseCase.execute(email, username, password);
      // Auto-login after successful registration
      final loginUseCase = await ref.read(loginUseCaseProvider.future);
      return await loginUseCase.execute(email, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading<UserProfile?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final logoutUseCase = await ref.read(logoutUseCaseProvider.future);
      await logoutUseCase.execute();
      return null;
    });
  }
}
