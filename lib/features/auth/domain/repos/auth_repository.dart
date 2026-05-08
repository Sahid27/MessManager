import '../entities/user.dart';

// শুধু কী কী করতে পারবে সেটা define করো
// কীভাবে করবে সেটা impl এ
abstract class AuthRepository {
  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  // App খুললে আগের login আছে কিনা দেখো
  Future<AppUser?> getCurrentUser();
}