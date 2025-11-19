import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../repositories/i_location_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

/// Use case for getting current location
class GetCurrentLocation implements UseCase<Location, NoParams> {
  final ILocationRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, Location>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}
