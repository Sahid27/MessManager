abstract class AuthEvent {}
class AuthCheckRequested  extends AuthEvent {}
class LogoutRequested     extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String name, email, password;
  RegisterRequested({required this.name, required this.email, required this.password});
}