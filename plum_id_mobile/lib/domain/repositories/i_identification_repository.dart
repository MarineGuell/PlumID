import 'package:dartz/dartz.dart';
import '../entities/bird_species.dart';
import '../entities/prediction.dart';
import '../../core/errors/failures.dart';

/// Repository interface for bird identification
abstract class IIdentificationRepository {
  /// Identifies a bird species from an image
  Future<Either<Failure, List<Prediction>>> identifyFromImage(
    String imagePath, {
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  });

  /// Gets detailed information about a specific species
  Future<Either<Failure, BirdSpecies>> getSpeciesDetails(String speciesId);

  /// Gets all available species
  Future<Either<Failure, List<BirdSpecies>>> getAllSpecies();
}
