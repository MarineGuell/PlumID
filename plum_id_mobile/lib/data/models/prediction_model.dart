import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/prediction.dart';

part 'prediction_model.freezed.dart';
part 'prediction_model.g.dart';

@freezed
class PredictionModel with _$PredictionModel {
  const PredictionModel._();

  const factory PredictionModel({
    required String speciesId,
    required String speciesName,
    required String scientificName,
    required double confidence,
    double? geographicWeight,
    double? temporalWeight,
    required double finalScore,
  }) = _PredictionModel;

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionModelFromJson(json);

  /// Convert model to entity
  Prediction toEntity() {
    return Prediction(
      speciesId: speciesId,
      speciesName: speciesName,
      scientificName: scientificName,
      confidence: confidence,
      geographicWeight: geographicWeight,
      temporalWeight: temporalWeight,
      finalScore: finalScore,
    );
  }

  /// Create model from entity
  factory PredictionModel.fromEntity(Prediction entity) {
    return PredictionModel(
      speciesId: entity.speciesId,
      speciesName: entity.speciesName,
      scientificName: entity.scientificName,
      confidence: entity.confidence,
      geographicWeight: entity.geographicWeight,
      temporalWeight: entity.temporalWeight,
      finalScore: entity.finalScore,
    );
  }
}
