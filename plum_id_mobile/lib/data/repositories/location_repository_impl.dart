import 'package:dartz/dartz.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/i_location_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements ILocationRepository {
  final ILocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    try {
      final location = await dataSource.getCurrentLocation();
      return Right(location.toEntity());
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasLocationPermission() async {
    try {
      final hasPermission = await dataSource.hasLocationPermission();
      return Right(hasPermission);
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await dataSource.requestLocationPermission();
      return Right(granted);
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final address = await dataSource.getAddressFromCoordinates(
        latitude,
        longitude,
      );
      return Right(address);
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return Left(LocationFailure('Unexpected error: $e'));
    }
  }
}
