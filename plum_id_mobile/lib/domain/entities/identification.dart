import 'package:equatable/equatable.dart';
import 'location.dart';
import 'prediction.dart';

/// Represents an identification attempt saved in history
class Identification extends Equatable {
  final String id;
  final String imageUrl;
  final String? localImagePath;
  final DateTime timestamp;
  final Location? location;
  final List<Prediction> predictions;
  final Prediction? selectedPrediction;

  const Identification({
    required this.id,
    required this.imageUrl,
    this.localImagePath,
    required this.timestamp,
    this.location,
    required this.predictions,
    this.selectedPrediction,
  });

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        localImagePath,
        timestamp,
        location,
        predictions,
        selectedPrediction,
      ];
}
