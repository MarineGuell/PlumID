import 'package:dio/dio.dart';
import '../models/bird_species_model.dart';
import '../models/prediction_model.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for bird identification API
abstract class IIdentificationRemoteDataSource {
  Future<List<PredictionModel>> identifyFromImage(
    String imagePath, {
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  });

  Future<BirdSpeciesModel> getSpeciesDetails(String speciesId);

  Future<List<BirdSpeciesModel>> getAllSpecies();
}

class IdentificationRemoteDataSource implements IIdentificationRemoteDataSource {
  final Dio dio;

  IdentificationRemoteDataSource(this.dio);

  @override
  Future<List<PredictionModel>> identifyFromImage(
    String imagePath, {
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) async {
    try {
      // Prepare form data with image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
      });

      final response = await dio.post('/identify', data: formData);

      if (response.statusCode == 200) {
        final predictions = (response.data['predictions'] as List)
            .map((json) => PredictionModel.fromJson(json))
            .toList();
        return predictions;
      } else {
        throw ServerException('Failed to identify bird: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<BirdSpeciesModel> getSpeciesDetails(String speciesId) async {
    try {
      final response = await dio.get('/species/$speciesId');

      if (response.statusCode == 200) {
        return BirdSpeciesModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get species details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<BirdSpeciesModel>> getAllSpecies() async {
    try {
      final response = await dio.get('/species');

      if (response.statusCode == 200) {
        final species = (response.data as List)
            .map((json) => BirdSpeciesModel.fromJson(json))
            .toList();
        return species;
      } else {
        throw ServerException('Failed to get species list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
