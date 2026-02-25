import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> execute() {
    return _repository.logout();
  }
}
