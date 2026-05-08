import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    // State পরিবর্তন হলে router কে জানাও
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthBloc>().stream,
    ),
    redirect: (ctx, state) {
      final authState = ctx.read<AuthBloc>().state;
      final isAuth = authState is AuthAuthenticated;
      final isLoading = authState is AuthInitial
                      || authState is AuthLoading;
      final onAuth = ['/login', '/register']
                       .contains(state.matchedLocation);

      if (isLoading) return '/';         // Splash
      if (!isAuth && !onAuth) return '/login';
      if (isAuth && onAuth) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/',
        builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',
        builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',
        builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard',
        builder: (_, __) => const Scaffold(
          body: Center(
            child: Text('Dashboard — দিন ৩ এ বানাবো'),
          ),
        )),
    ],
  );
}

// BLoC stream কে Listenable এ রূপান্তর
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}