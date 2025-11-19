import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../../core/errors/failures.dart';

/// Repository interface for location services
abstract class ILocationRepository {
  /// Gets the current device location
  Future<Either<Failure, Location>> getCurrentLocation();

  /// Checks if location permissions are granted
  Future<Either<Failure, bool>> hasLocationPermission();

  /// Requests location permissions
  Future<Either<Failure, bool>> requestLocationPermission();

  /// Gets address from coordinates (reverse geocoding)
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  );
}
