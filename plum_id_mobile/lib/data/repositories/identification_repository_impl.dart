import 'package:dartz/dartz.dart';
import '../../domain/entities/bird_species.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/i_identification_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/identification_remote_datasource.dart';

class IdentificationRepositoryImpl implements IIdentificationRepository {
  final IIdentificationRemoteDataSource remoteDataSource;

  IdentificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Prediction>>> identifyFromImage(
    String imagePath, {
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    try {
      final predictions = await remoteDataSource.identifyFromImage(
        imagePath,
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );
      return Right(predictions.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, BirdSpecies>> getSpeciesDetails(
    String speciesId,
  ) async {
    try {
      final species = await remoteDataSource.getSpeciesDetails(speciesId);
      return Right(species.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BirdSpecies>>> getAllSpecies() async {
    try {
      final species = await remoteDataSource.getAllSpecies();
      return Right(species.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
