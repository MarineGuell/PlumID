import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<UserProfileModel> getProfile() async {
    // Simuler une requête réseau (mock)
    await Future.delayed(const Duration(seconds: 1));

    // Simuler des données retournées
    return const UserProfileModel(
      id: 1,
      username: 'marineguell',
      email: 'marine.guell@plum-id.com',
    );
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    // Simuler une mise à jour réseau (mock)
    await Future.delayed(const Duration(seconds: 1));

    // Retourner le profil mis à jour
    return profile;
  }

  @override
  Future<void> deleteAccount() async {
    // Simuler une requête réseau (mock)
    await Future.delayed(const Duration(seconds: 1));
  }
}
