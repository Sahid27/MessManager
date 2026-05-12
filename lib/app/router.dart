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
import '../features/mess/presentation/screens/settings_screen.dart';
import '../features/meals/presentation/screens/meal_sheet_screen.dart';
import '../features/meals/presentation/screens/add_meal_screen.dart';
import '../features/costs/presentation/screens/cost_history_screen.dart';
import '../features/costs/presentation/screens/add_cost_screen.dart';
import '../features/costs/presentation/screens/house_cost_screen.dart';
import '../features/summary/presentation/screens/summary_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthBloc>().stream,
    ),
    redirect: (ctx, state) {
      final authState = ctx.read<AuthBloc>().state;
      final loc = state.matchedLocation;

      if (authState is AuthInitial || authState is AuthLoading) {
        return '/';
      }
      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (loc == '/login' || loc == '/register') return null;
        return '/login';
      }
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        if (loc == '/login' || loc == '/register' || loc == '/') {
          return user.hasJoinedMess ? '/dashboard' : '/setup';
        }
        if (!user.hasJoinedMess && loc != '/setup') {
          return '/setup';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/setup', builder: (_, __) => const SetupMessScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/meals', builder: (_, __) => const MealSheetScreen()),
      GoRoute(path: '/meals/add', builder: (_, __) => const AddMealScreen()),
      GoRoute(path: '/costs', builder: (_, __) => const CostHistoryScreen()),
      GoRoute(path: '/costs/add', builder: (_, __) => const AddCostScreen()),
      GoRoute(path: '/house-costs', builder: (_, __) => const HouseCostScreen()),
      GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}