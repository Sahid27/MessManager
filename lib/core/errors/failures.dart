// lib/core/errors/failures.dart

// যখন কিছু ভুল হয় তখন এই class গুলো ব্যবহার হবে
abstract class Failure {
  final String message;

  const Failure(this.message);
}

// Login/Register সমস্যা
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// ইন্টারনেট সমস্যা
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Firebase/Server সমস্যা
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Local storage সমস্যা
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}