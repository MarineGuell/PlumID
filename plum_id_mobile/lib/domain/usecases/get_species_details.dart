import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/bird_species.dart';
import '../repositories/i_identification_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

/// Use case for getting species details
class GetSpeciesDetails implements UseCase<BirdSpecies, GetSpeciesDetailsParams> {
  final IIdentificationRepository repository;

  GetSpeciesDetails(this.repository);

  @override
  Future<Either<Failure, BirdSpecies>> call(
    GetSpeciesDetailsParams params,
  ) async {
    return await repository.getSpeciesDetails(params.speciesId);
  }
}

class GetSpeciesDetailsParams extends Equatable {
  final String speciesId;

  const GetSpeciesDetailsParams({required this.speciesId});

  @override
  List<Object> get props => [speciesId];
}
