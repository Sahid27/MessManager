import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/mess/presentation/screens/setup_mess_screen.dart';
import '../features/mess/presentation/screens/dashboard_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthBloc>().stream,
    ),

    redirect: (ctx, state) {
      final authState = ctx.read<AuthBloc>().state;
      final loc       = state.matchedLocation;

      // ১. এখনো loading — Splash দেখাও
      if (authState is AuthInitial ||
          authState is AuthLoading) {
        return '/';
      }

      // ২. Login নেই — Login page এ পাঠাও
      if (authState is AuthUnauthenticated ||
          authState is AuthError) {
        if (loc == '/login' || loc == '/register')
          return null;
        return '/login';
      }

      // ৩. Login আছে
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // Login/Register page এ থাকলে সরিয়ে দাও
        if (loc == '/login' || loc == '/register') {
          // Mess আছে? → Dashboard, নেই? → Setup
          return user.hasJoinedMess
              ? '/dashboard'
              : '/setup';
        }

        // Splash এ আছে — সরিয়ে দাও
        if (loc == '/') {
          return user.hasJoinedMess
              ? '/dashboard'
              : '/setup';
        }

        // Mess নেই কিন্তু dashboard এ যাচ্ছে — setup এ পাঠাও
        if (!user.hasJoinedMess && loc != '/setup') {
          return '/setup';
        }
      }

      return null; // কিছু করার নেই
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (_, __) => const SetupMessScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),

      // Day 4 এ যোগ হবে
      GoRoute(
        path: '/meals',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('মিল — দিন ৪ এ আসবে'))),
      ),
      GoRoute(
        path: '/costs',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('খরচ — দিন ৫ এ আসবে'))),
      ),
      GoRoute(
        path: '/summary',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('সারসংক্ষেপ — দিন ৬ এ আসবে'))),
      ),
      GoRoute(
        path: '/house-costs',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('বাসার খরচ — দিন ৫ এ আসবে'))),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}