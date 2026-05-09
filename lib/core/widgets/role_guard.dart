import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/mess/presentation/bloc/mess_bloc.dart';
import '../../features/mess/presentation/bloc/mess_state.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  const RoleGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext ctx) {
    final state = ctx.watch<MessBloc>().state;
    if (state is MessLoaded) {
      final isManager =
        state.currentMember?.isManager ?? false;
      if (isManager) return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

// ব্যবহার — FAB শুধু manager দেখতে পাবে
// RoleGuard(
//   child: FloatingActionButton(
//     onPressed: () => context.push('/meals/add'),
//     child: Icon(Icons.add),
//   ),
// )