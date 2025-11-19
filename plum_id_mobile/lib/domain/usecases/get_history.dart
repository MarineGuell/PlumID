import 'package:dartz/dartz.dart';
import '../entities/identification.dart';
import '../repositories/i_history_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

/// Use case for getting identification history
class GetHistory implements UseCase<List<Identification>, NoParams> {
  final IHistoryRepository repository;

  GetHistory(this.repository);

  @override
  Future<Either<Failure, List<Identification>>> call(NoParams params) async {
    return await repository.getHistory();
  }
}
