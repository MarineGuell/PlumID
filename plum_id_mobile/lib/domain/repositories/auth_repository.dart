import 'package:plum_id_mobile/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> login(String email, String password);
  Future<void> register(String email, String username, String password);
  Future<void> logout();
  Future<UserProfile> getMe();
  bool isAuthenticated();
}
