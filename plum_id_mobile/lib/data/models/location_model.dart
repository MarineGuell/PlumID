import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/location.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
class LocationModel with _$LocationModel {
  const LocationModel._();

  const factory LocationModel({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  /// Convert model to entity
  Location toEntity() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
    );
  }

  /// Create model from entity
  factory LocationModel.fromEntity(Location entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      address: entity.address,
    );
  }
}
