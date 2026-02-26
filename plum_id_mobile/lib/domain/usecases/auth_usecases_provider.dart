import 'package:plum_id_mobile/data/repositories/auth_repository_impl.dart';
import 'package:plum_id_mobile/domain/usecases/get_me_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/login_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/logout_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/register_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_usecases_provider.g.dart';

@riverpod
Future<LoginUseCase> loginUseCase(Ref ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(repository);
}

@riverpod
Future<RegisterUseCase> registerUseCase(Ref ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return RegisterUseCase(repository);
}

@riverpod
Future<LogoutUseCase> logoutUseCase(Ref ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LogoutUseCase(repository);
}

@riverpod
Future<GetMeUseCase> getMeUseCase(Ref ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return GetMeUseCase(repository);
}
