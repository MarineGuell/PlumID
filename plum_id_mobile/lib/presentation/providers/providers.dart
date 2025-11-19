import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/identification_remote_datasource.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/identification_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/i_identification_repository.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../domain/repositories/i_location_repository.dart';
import '../../domain/usecases/identify_bird.dart';
import '../../domain/usecases/get_species_details.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/save_identification.dart';
import '../../domain/usecases/get_current_location.dart';

part 'providers.g.dart';

// ============================================================================
// Infrastructure Providers
// ============================================================================

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for logging, auth, etc.
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

// ============================================================================
// Data Source Providers
// ============================================================================

@riverpod
IIdentificationRemoteDataSource identificationRemoteDataSource(
  IdentificationRemoteDataSourceRef ref,
) {
  return IdentificationRemoteDataSource(ref.watch(dioProvider));
}

@riverpod
IHistoryLocalDataSource historyLocalDataSource(
  HistoryLocalDataSourceRef ref,
) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return sharedPrefs.when(
    data: (prefs) => HistoryLocalDataSource(prefs),
    loading: () => throw Exception('SharedPreferences not ready'),
    error: (err, stack) => throw err,
  );
}

@riverpod
ILocationDataSource locationDataSource(LocationDataSourceRef ref) {
  return LocationDataSource();
}

// ============================================================================
// Repository Providers
// ============================================================================

@riverpod
IIdentificationRepository identificationRepository(
  IdentificationRepositoryRef ref,
) {
  return IdentificationRepositoryImpl(
    ref.watch(identificationRemoteDataSourceProvider),
  );
}

@riverpod
IHistoryRepository historyRepository(HistoryRepositoryRef ref) {
  return HistoryRepositoryImpl(
    ref.watch(historyLocalDataSourceProvider),
  );
}

@riverpod
ILocationRepository locationRepository(LocationRepositoryRef ref) {
  return LocationRepositoryImpl(
    ref.watch(locationDataSourceProvider),
  );
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
IdentifyBird identifyBirdUseCase(IdentifyBirdUseCaseRef ref) {
  return IdentifyBird(ref.watch(identificationRepositoryProvider));
}

@riverpod
GetSpeciesDetails getSpeciesDetailsUseCase(GetSpeciesDetailsUseCaseRef ref) {
  return GetSpeciesDetails(ref.watch(identificationRepositoryProvider));
}

@riverpod
GetHistory getHistoryUseCase(GetHistoryUseCaseRef ref) {
  return GetHistory(ref.watch(historyRepositoryProvider));
}

@riverpod
SaveIdentification saveIdentificationUseCase(
  SaveIdentificationUseCaseRef ref,
) {
  return SaveIdentification(ref.watch(historyRepositoryProvider));
}

@riverpod
GetCurrentLocation getCurrentLocationUseCase(
  GetCurrentLocationUseCaseRef ref,
) {
  return GetCurrentLocation(ref.watch(locationRepositoryProvider));
}
