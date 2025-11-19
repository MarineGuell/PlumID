import 'package:dartz/dartz.dart';
import '../entities/identification.dart';
import '../../core/errors/failures.dart';

/// Repository interface for managing identification history
abstract class IHistoryRepository {
  /// Saves an identification to history
  Future<Either<Failure, void>> saveIdentification(Identification identification);

  /// Gets all identifications from history
  Future<Either<Failure, List<Identification>>> getHistory();

  /// Gets a specific identification by id
  Future<Either<Failure, Identification>> getIdentificationById(String id);

  /// Deletes an identification from history
  Future<Either<Failure, void>> deleteIdentification(String id);

  /// Clears all history
  Future<Either<Failure, void>> clearHistory();
}
