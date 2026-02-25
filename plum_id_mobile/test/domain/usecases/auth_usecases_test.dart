import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plum_id_mobile/domain/entities/user_profile.dart';
import 'package:plum_id_mobile/domain/repositories/auth_repository.dart';
import 'package:plum_id_mobile/domain/usecases/get_me_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/login_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/logout_usecase.dart';
import 'package:plum_id_mobile/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetMeUseCase getMeUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
    logoutUseCase = LogoutUseCase(mockRepository);
    getMeUseCase = GetMeUseCase(mockRepository);
  });

  const tUserProfile = UserProfile(
    id: 1,
    username: 'tester',
    email: 'test@example.com',
  );
  const tEmail = 'test@example.com';
  const tPassword = 'Password123!';
  const tUsername = 'tester';

  group('Auth UseCases', () {
    test(
      'LoginUseCase should call login on repository and return UserProfile',
      () async {
        when(
          () => mockRepository.login(tEmail, tPassword),
        ).thenAnswer((_) async => tUserProfile);

        final result = await loginUseCase.execute(tEmail, tPassword);

        expect(result, tUserProfile);
        verify(() => mockRepository.login(tEmail, tPassword)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('RegisterUseCase should call register on repository', () async {
      when(
        () => mockRepository.register(tEmail, tUsername, tPassword),
      ).thenAnswer((_) async => {});

      await registerUseCase.execute(tEmail, tUsername, tPassword);

      verify(
        () => mockRepository.register(tEmail, tUsername, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('LogoutUseCase should call logout on repository', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => {});

      await logoutUseCase.execute();

      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'GetMeUseCase should call getMe on repository and return UserProfile',
      () async {
        when(
          () => mockRepository.getMe(),
        ).thenAnswer((_) async => tUserProfile);

        final result = await getMeUseCase.execute();

        expect(result, tUserProfile);
        verify(() => mockRepository.getMe()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
