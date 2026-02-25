import 'package:plum_id_mobile/domain/entities/user_profile.dart';
import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;

  GetMeUseCase(this._repository);

  Future<UserProfile> execute() {
    return _repository.getMe();
  }
}
