import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';
import '../../core/errors/exceptions.dart';

/// Data source for location services
abstract class ILocationDataSource {
  Future<LocationModel> getCurrentLocation();
  Future<bool> hasLocationPermission();
  Future<bool> requestLocationPermission();
  Future<String> getAddressFromCoordinates(double latitude, double longitude);
}

class LocationDataSource implements ILocationDataSource {
  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw LocationException('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      String? address;
      try {
        address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        // Address is optional, continue without it
      }

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Failed to get current location: $e');
    }
  }

  @override
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      throw LocationException('Failed to check location permission: $e');
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      throw LocationException('Failed to request location permission: $e');
    }
  }

  @override
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        throw LocationException('No address found for coordinates');
      }

      final placemark = placemarks.first;
      final parts = [
        if (placemark.locality != null) placemark.locality,
        if (placemark.administrativeArea != null) placemark.administrativeArea,
        if (placemark.country != null) placemark.country,
      ];

      return parts.join(', ');
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Failed to get address: $e');
    }
  }
}
