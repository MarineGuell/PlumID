import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/identify_bird.dart';
import '../../domain/usecases/usecase.dart';
import 'providers.dart';

part 'identification_provider.g.dart';

/// State for identification feature
class IdentificationState {
  final List<Prediction> predictions;
  final Location? location;
  final String? imagePath;
  final bool isLoading;
  final String? error;

  const IdentificationState({
    this.predictions = const [],
    this.location,
    this.imagePath,
    this.isLoading = false,
    this.error,
  });

  IdentificationState copyWith({
    List<Prediction>? predictions,
    Location? location,
    String? imagePath,
    bool? isLoading,
    String? error,
  }) {
    return IdentificationState(
      predictions: predictions ?? this.predictions,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class IdentificationNotifier extends _$IdentificationNotifier {
  @override
  IdentificationState build() {
    return const IdentificationState();
  }

  /// Identifies a bird from an image
  Future<void> identifyBird(String imagePath) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      imagePath: imagePath,
    );

    // Get current location if available
    Location? location;
    final getCurrentLocation = ref.read(getCurrentLocationUseCaseProvider);
    final locationResult = await getCurrentLocation(NoParams());
    locationResult.fold(
      (failure) {
        // Location is optional, continue without it
        location = null;
      },
      (loc) {
        location = loc;
      },
    );

    // Identify the bird
    final identifyBird = ref.read(identifyBirdUseCaseProvider);
    final params = IdentifyBirdParams(
      imagePath: imagePath,
      latitude: location?.latitude,
      longitude: location?.longitude,
      timestamp: DateTime.now(),
    );

    final result = await identifyBird(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (predictions) {
        state = state.copyWith(
          isLoading: false,
          predictions: predictions,
          location: location,
          error: null,
        );
      },
    );
  }

  /// Clears the current identification
  void clear() {
    state = const IdentificationState();
  }
}
