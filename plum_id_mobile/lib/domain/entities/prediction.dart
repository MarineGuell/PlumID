import 'package:equatable/equatable.dart';

/// Represents a prediction result with confidence score
class Prediction extends Equatable {
  final String speciesId;
  final String speciesName;
  final String scientificName;
  final double confidence;
  final double? geographicWeight;
  final double? temporalWeight;
  final double finalScore;

  const Prediction({
    required this.speciesId,
    required this.speciesName,
    required this.scientificName,
    required this.confidence,
    this.geographicWeight,
    this.temporalWeight,
    required this.finalScore,
  });

  @override
  List<Object?> get props => [
        speciesId,
        speciesName,
        scientificName,
        confidence,
        geographicWeight,
        temporalWeight,
        finalScore,
      ];
}
