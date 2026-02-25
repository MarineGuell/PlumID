import 'package:plum_id_mobile/domain/entities/user_profile.dart';
import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserProfile> execute(String email, String password) {
    return _repository.login(email, password);
  }
}
