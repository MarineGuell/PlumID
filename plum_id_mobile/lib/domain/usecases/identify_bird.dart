import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/prediction.dart';
import '../repositories/i_identification_repository.dart';
import '../../core/errors/failures.dart';
import 'usecase.dart';

/// Use case for identifying a bird from an image
class IdentifyBird implements UseCase<List<Prediction>, IdentifyBirdParams> {
  final IIdentificationRepository repository;

  IdentifyBird(this.repository);

  @override
  Future<Either<Failure, List<Prediction>>> call(
    IdentifyBirdParams params,
  ) async {
    return await repository.identifyFromImage(
      params.imagePath,
      latitude: params.latitude,
      longitude: params.longitude,
      timestamp: params.timestamp,
    );
  }
}

class IdentifyBirdParams extends Equatable {
  final String imagePath;
  final double? latitude;
  final double? longitude;
  final DateTime? timestamp;

  const IdentifyBirdParams({
    required this.imagePath,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  @override
  List<Object?> get props => [imagePath, latitude, longitude, timestamp];
}
