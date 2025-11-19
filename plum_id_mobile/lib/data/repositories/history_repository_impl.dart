import 'package:dartz/dartz.dart';
import '../../domain/entities/identification.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/history_local_datasource.dart';
import '../models/identification_model.dart';

class HistoryRepositoryImpl implements IHistoryRepository {
  final IHistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> saveIdentification(
    Identification identification,
  ) async {
    try {
      final model = IdentificationModel.fromEntity(identification);
      await localDataSource.saveIdentification(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Identification>>> getHistory() async {
    try {
      final models = await localDataSource.getHistory();
      return Right(models.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Identification>> getIdentificationById(
    String id,
  ) async {
    try {
      final model = await localDataSource.getIdentificationById(id);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteIdentification(String id) async {
    try {
      await localDataSource.deleteIdentification(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
