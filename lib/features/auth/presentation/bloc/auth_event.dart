// UI থেকে BLoC কে যা বলা হয়
abstract class AuthEvent {}

// App চালু হলে check করো আগে login ছিল কিনা
class AuthCheckRequested extends AuthEvent {}

// Login বাটন চাপলে
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({
    required this.email,
    required this.password,
  });
}

// Register বাটন চাপলে
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

// Logout বাটন চাপলে
class LogoutRequested extends AuthEvent {}