// lib/data/exceptions/api_exceptions.dart

/// Custom exception for camera-related errors
class CameraException implements Exception {
  final String code;
  final String description;

  CameraException(this.code, this.description);

  @override
  String toString() => 'CameraException($code): $description';
}

/// Custom exception for image compression errors
class ImageCompressionException implements Exception {
  final String message;

  ImageCompressionException(this.message);

  @override
  String toString() => 'ImageCompressionException: $message';
}
