import 'package:equatable/equatable.dart';

/// Represents geographic coordinates
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;

  const Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, address];
}
