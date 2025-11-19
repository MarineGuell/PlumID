import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/bird_species.dart';

part 'bird_species_model.freezed.dart';
part 'bird_species_model.g.dart';

@freezed
class BirdSpeciesModel with _$BirdSpeciesModel {
  const BirdSpeciesModel._();

  const factory BirdSpeciesModel({
    required String id,
    required String commonName,
    required String scientificName,
    String? description,
    String? habitat,
    String? conservationStatus,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> regions,
    @Default([]) List<int> observationMonths,
  }) = _BirdSpeciesModel;

  factory BirdSpeciesModel.fromJson(Map<String, dynamic> json) =>
      _$BirdSpeciesModelFromJson(json);

  /// Convert model to entity
  BirdSpecies toEntity() {
    return BirdSpecies(
      id: id,
      commonName: commonName,
      scientificName: scientificName,
      description: description,
      habitat: habitat,
      conservationStatus: conservationStatus,
      imageUrls: imageUrls,
      regions: regions,
      observationMonths: observationMonths,
    );
  }

  /// Create model from entity
  factory BirdSpeciesModel.fromEntity(BirdSpecies entity) {
    return BirdSpeciesModel(
      id: entity.id,
      commonName: entity.commonName,
      scientificName: entity.scientificName,
      description: entity.description,
      habitat: entity.habitat,
      conservationStatus: entity.conservationStatus,
      imageUrls: entity.imageUrls,
      regions: entity.regions,
      observationMonths: entity.observationMonths,
    );
  }
}
