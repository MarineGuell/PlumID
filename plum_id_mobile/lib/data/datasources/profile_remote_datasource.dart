import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<UserProfileModel> getProfile() async {
    // Simuler une requête réseau (mock)
    await Future.delayed(const Duration(seconds: 1));

    // Simuler des données retournées
    return const UserProfileModel(
      id: 'usr_123456789',
      firstName: 'Marine',
      lastName: 'Guell',
      email: 'marine.guell@example.com',
    );
  }
}
