import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> execute(String email, String username, String password) {
    return _repository.register(email, username, password);
  }
}
