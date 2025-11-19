/// Base exception class
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Location-related exceptions
class LocationException extends AppException {
  const LocationException(super.message);
}

/// Image processing exceptions
class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message);
}
