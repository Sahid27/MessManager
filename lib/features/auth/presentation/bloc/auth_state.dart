import '../../domain/entities/user.dart';

abstract class AuthState {}
class AuthInitial         extends AuthState {}
class AuthLoading         extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}