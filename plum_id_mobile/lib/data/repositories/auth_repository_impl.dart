import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plum_id_mobile/core/utils/token_storage.dart';
import 'package:plum_id_mobile/data/datasources/auth_remote_data_source.dart';
import 'package:plum_id_mobile/domain/entities/user_profile.dart';
import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<UserProfile> login(String email, String password) async {
    final token = await _remoteDataSource.login(email, password);
    await _tokenStorage.saveToken(token);
    return getMe();
  }

  @override
  Future<void> register(String email, String username, String password) async {
    await _remoteDataSource.register(email, username, password);
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  @override
  Future<UserProfile> getMe() async {
    final userModel = await _remoteDataSource.getMe();
    return userModel.toEntity();
  }

  @override
  bool isAuthenticated() {
    return _tokenStorage.hasToken();
  }
}

@riverpod
Future<AuthRepository> authRepository(Ref ref) async {
  final remoteDataSource = await ref.watch(authRemoteDataSourceProvider.future);
  final tokenStorage = await ref.watch(tokenStorageProvider.future);
  return AuthRepositoryImpl(remoteDataSource, tokenStorage);
}
