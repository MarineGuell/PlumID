import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/identification.dart';
import '../../domain/usecases/save_identification.dart';
import '../../domain/usecases/usecase.dart';
import 'providers.dart';

part 'history_provider.g.dart';

/// State for history feature
class HistoryState {
  final List<Identification> identifications;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.identifications = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<Identification>? identifications,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      identifications: identifications ?? this.identifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  HistoryState build() {
    loadHistory();
    return const HistoryState();
  }

  /// Loads the history from storage
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    final getHistory = ref.read(getHistoryUseCaseProvider);
    final result = await getHistory(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (identifications) {
        state = state.copyWith(
          isLoading: false,
          identifications: identifications,
          error: null,
        );
      },
    );
  }

  /// Saves a new identification to history
  Future<void> saveIdentification(Identification identification) async {
    final saveIdentification = ref.read(saveIdentificationUseCaseProvider);
    final params = SaveIdentificationParams(identification: identification);
    final result = await saveIdentification(params);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Reload history after saving
        loadHistory();
      },
    );
  }
}
