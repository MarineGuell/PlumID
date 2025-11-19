import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/identification.dart';
import 'location_model.dart';
import 'prediction_model.dart';

part 'identification_model.freezed.dart';
part 'identification_model.g.dart';

@freezed
class IdentificationModel with _$IdentificationModel {
  const IdentificationModel._();

  const factory IdentificationModel({
    required String id,
    required String imageUrl,
    String? localImagePath,
    required DateTime timestamp,
    LocationModel? location,
    required List<PredictionModel> predictions,
    PredictionModel? selectedPrediction,
  }) = _IdentificationModel;

  factory IdentificationModel.fromJson(Map<String, dynamic> json) =>
      _$IdentificationModelFromJson(json);

  /// Convert model to entity
  Identification toEntity() {
    return Identification(
      id: id,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
      timestamp: timestamp,
      location: location?.toEntity(),
      predictions: predictions.map((p) => p.toEntity()).toList(),
      selectedPrediction: selectedPrediction?.toEntity(),
    );
  }

  /// Create model from entity
  factory IdentificationModel.fromEntity(Identification entity) {
    return IdentificationModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      localImagePath: entity.localImagePath,
      timestamp: entity.timestamp,
      location: entity.location != null
          ? LocationModel.fromEntity(entity.location!)
          : null,
      predictions:
          entity.predictions.map((p) => PredictionModel.fromEntity(p)).toList(),
      selectedPrediction: entity.selectedPrediction != null
          ? PredictionModel.fromEntity(entity.selectedPrediction!)
          : null,
    );
  }
}
