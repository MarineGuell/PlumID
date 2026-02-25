import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/profile_remote_datasource.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/profile_repository.dart';

part 'profile_notifier.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  // En production, on utiliserait un provider d'injection de dépendance
  return ProfileRepositoryImpl(remoteDataSource: ProfileRemoteDataSourceImpl());
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<UserProfile> build() async {
    return _fetchProfile();
  }

  Future<UserProfile> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.getProfile();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (profile) => profile,
    );
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }
}
