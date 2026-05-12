import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/mess/presentation/bloc/mess_bloc.dart';
import '../../features/mess/presentation/bloc/mess_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const RoleGuard({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final messState = context.watch<MessBloc>().state;

    if (authState is AuthAuthenticated && messState is MessLoaded) {
      final me = messState.members.firstWhere(
        (m) => m.uid == authState.user.uid,
        orElse: () => messState.members.first,
      );
      if (me.isManager) return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}