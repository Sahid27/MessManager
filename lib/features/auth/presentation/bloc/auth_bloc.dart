import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepoImpl _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter emit) async {
    emit(AuthLoading());
    final user = await _repo.getCurrentUser();
    emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
  }

  Future<void> _onLogin(LoginRequested e, Emitter emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(email: e.email, password: e.password);
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onRegister(RegisterRequested e, Emitter emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.register(
        name: e.name, email: e.email, password: e.password);
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter emit) async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }
}