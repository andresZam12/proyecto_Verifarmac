// Internal exceptions for the data layer.
// Exceptions only exist in the data layer (data/).
// Repositories catch them and convert them into Failures
// before reaching the domain or UI.

class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
}

class NoConnectionException implements Exception {
  const NoConnectionException();
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Not found']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Local database error']);
  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Authentication error']);
  final String message;
}
