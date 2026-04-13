// Failure classes returned by the domain layer.
// Instead of throwing exceptions, use cases return a Failure.

abstract class Failure {
  const Failure(this.message);
  final String message;
}

// No internet connection
class NoConnectionFailure extends Failure {
  const NoConnectionFailure() : super('No internet connection');
}

// Server or API error
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

// Medicine not found in the database
class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Medicine not found');
}

// Error reading or writing to local database
class CacheFailure extends Failure {
  const CacheFailure() : super('Error accessing local history');
}

// Camera or location permission denied
class PermissionFailure extends Failure {
  const PermissionFailure() : super('Permission denied');
}

// Could not read the medicine code
class ScanFailure extends Failure {
  const ScanFailure() : super('Could not read the code');
}

// Authentication error
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error']);
}

// Generic error for unhandled cases
class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred');
}
