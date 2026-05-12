import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/widgets/gradient_avatar.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/cost_entry.dart';
import '../bloc/cost_bloc.dart';
import '../bloc/cost_event.dart';
import '../bloc/cost_state.dart';

class CostHistoryScreen extends StatefulWidget {
  const CostHistoryScreen({super.key});

  @override
  State<CostHistoryScreen> createState() => _State();
}

class _State extends State<CostHistoryScreen> {
  DateTime _month = DateTime.now();

  String get _monthKey {
    final m = _month.month.toString().padLeft(2, '0');
    return '${_month.year}-$m';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth =
          context.read<AuthBloc>().state as AuthAuthenticated;

      context.read<CostBloc>().add(
            LoadCostsRequested(
              messId: auth.user.messId!,
              month: _monthKey,
            ),
          );
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });

    final auth =
        context.read<AuthBloc>().state as AuthAuthenticated;

    context.read<CostBloc>().add(
          LoadCostsRequested(
            messId: auth.user.messId!,
            month: _monthKey,
          ),
        );
  }

void _togglePaid(CostEntry e, String month) {
  final auth = context.read<AuthBloc>().state as AuthAuthenticated;

  context.read<CostBloc>().add(
    TogglePaidRequested(
      messId: auth.user.messId!,
      month: month,
      costId: e.id,
      isPaid: !e.isPaid,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [

          // ── HEADER ─────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.gradTeal,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: Colors.white),

                    const SizedBox(width: 10),

                    const Text(
                      'খরচের ইতিহাস',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const Spacer(),

                    RoleGuard(
                      child: IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.white),
                        onPressed: () =>
                            context.push('/costs/add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── MONTH SELECTOR ─────────────
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_month),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // ── STATS ───────────────────────
          BlocBuilder<CostBloc, CostState>(
            builder: (_, state) {
              if (state is! CostLoaded) {
                return const SizedBox();
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _StatBox(
                      'মোট',
                      '৳${state.totalCost.toStringAsFixed(0)}',
                      const Color(0xFFEDE9FE),
                      const Color(0xFF3C3489),
                    ),
                    _StatBox(
                      'পরিশোধিত',
                      '৳${state.paidTotal.toStringAsFixed(0)}',
                      const Color(0xFFDCFCE7),
                      const Color(0xFF065F46),
                    ),
                    _StatBox(
                      'বাকি',
                      '৳${state.dueTotal.toStringAsFixed(0)}',
                      const Color(0xFFFEE2E2),
                      const Color(0xFF991B1B),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // ── LIST ─────────────────────────
          Expanded(
            child: BlocBuilder<CostBloc, CostState>(
              builder: (ctx, state) {
                if (state is CostLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is CostError) {
                  return Center(child: Text(state.msg));
                }

                if (state is! CostLoaded ||
                    state.entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'এই মাসে কোনো খরচ নেই',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.entries.length,
                  itemBuilder: (_, i) {
                    return _buildCostItem(
                      state.entries[i],
                      _monthKey,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── COST ITEM (FINAL UI) ─────────────
  Widget _buildCostItem(CostEntry e, String month) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: e.isPaid
                  ? AppTheme.gradTeal
                  : AppTheme.gradAmber,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🛒',
                  style: TextStyle(fontSize: 18)),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.paidByName} • ${e.type.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy')
                      .format(e.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${e.amount.toStringAsFixed(0)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              RoleGuard(
                child: GestureDetector(
                  onTap: () => _togglePaid(e, month),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: e.isPaid
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.isPaid ? 'Paid ✓' : 'Due',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: e.isPaid
                            ? const Color(0xFF065F46)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── STAT BOX ───────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value;
  final Color bg, fg;

  const _StatBox(this.label, this.value, this.bg, this.fg);

  @override
  Widget build(BuildContext _) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: fg.withOpacity(.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}