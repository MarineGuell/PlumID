import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/identification.dart';
import '../repositories/i_history_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

/// Use case for saving an identification to history
class SaveIdentification implements UseCase<void, SaveIdentificationParams> {
  final IHistoryRepository repository;

  SaveIdentification(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveIdentificationParams params) async {
    return await repository.saveIdentification(params.identification);
  }
}

class SaveIdentificationParams extends Equatable {
  final Identification identification;

  const SaveIdentificationParams({required this.identification});

  @override
  List<Object> get props => [identification];
}
