class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';
  static const int apiTimeout = 30000; // 30 seconds

  // Image Configuration
  static const double maxImageSizeMB = 5.0;
  static const int imageQuality = 85;

  // Location Configuration
  static const double defaultLatitude = 48.8566; // Paris
  static const double defaultLongitude = 2.3522;
  static const double locationAccuracy = 100.0; // meters

  // Cache Configuration
  static const int maxCacheAge = 7; // days
  static const int maxHistoryItems = 100;

  // Prediction Configuration
  static const int topPredictionsCount = 5;
  static const double minConfidenceThreshold = 0.3;

  // App Info
  static const String appName = "Plum'ID";
  static const String appVersion = '1.0.0';
}
