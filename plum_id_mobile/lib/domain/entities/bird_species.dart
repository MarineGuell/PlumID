import 'package:equatable/equatable.dart';

/// Represents a bird species in the domain layer
class BirdSpecies extends Equatable {
  final String id;
  final String commonName;
  final String scientificName;
  final String? description;
  final String? habitat;
  final String? conservationStatus;
  final List<String> imageUrls;
  final List<String> regions;
  final List<int> observationMonths; // 1-12

  const BirdSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.description,
    this.habitat,
    this.conservationStatus,
    this.imageUrls = const [],
    this.regions = const [],
    this.observationMonths = const [],
  });

  @override
  List<Object?> get props => [
        id,
        commonName,
        scientificName,
        description,
        habitat,
        conservationStatus,
        imageUrls,
        regions,
        observationMonths,
      ];
}
