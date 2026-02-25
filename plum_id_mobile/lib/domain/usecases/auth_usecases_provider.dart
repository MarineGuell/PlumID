import 'package:plum_id_mobile/data/repositories/auth_repository_impl.dart';
import 'package:plum_id_mobile/domain/usecases/get_me_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/login_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/logout_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/register_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_usecases_provider.g.dart';

@riverpod
Future<LoginUseCase> loginUseCase(LoginUseCaseRef ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(repository);
}

@riverpod
Future<RegisterUseCase> registerUseCase(RegisterUseCaseRef ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return RegisterUseCase(repository);
}

@riverpod
Future<LogoutUseCase> logoutUseCase(LogoutUseCaseRef ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LogoutUseCase(repository);
}

@riverpod
Future<GetMeUseCase> getMeUseCase(GetMeUseCaseRef ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return GetMeUseCase(repository);
}
