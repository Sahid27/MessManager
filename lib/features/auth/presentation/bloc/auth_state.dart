import '../../domain/entities/user.dart';

// BLoC থেকে UI কে যা জানানো হয়
abstract class AuthState {}

// শুরুতে — কিছু জানি না
class AuthInitial extends AuthState {}

// কাজ চলছে — loading দেখাও
class AuthLoading extends AuthState {}

// Login সফল — user পাওয়া গেছে
class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

// Login নেই — Login page দেখাও
class AuthUnauthenticated extends AuthState {}

// কিছু ভুল হয়েছে — error দেখাও
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}