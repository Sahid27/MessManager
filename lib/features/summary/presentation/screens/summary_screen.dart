import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/gradient_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';

import '../../domain/entities/member_balance.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _State();
}

class _State extends State<SummaryScreen> {
  DateTime _month = DateTime.now();

  List<MemberBalance> _balances = [];
  double _totalCost = 0;
  double _mealRate = 0;
  int _totalMeals = 0;
  bool _loading = true;

  String get _monthKey {
    final m = _month.month.toString().padLeft(2, '0');
    return '${_month.year}-$m';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // TODO: তোমার repo logic same থাকবে
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _balances = [];
      _totalCost = 0;
      _mealRate = 0;
      _totalMeals = 0;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
    _load();
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
              gradient: AppTheme.gradPrimary,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মাসিক সারসংক্ষেপ 📊',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_month),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.white),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── STATS BAR ───────────────────
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.gradPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SumCell(
                  'মোট সংগ্রহ',
                  '৳${_totalCost.toStringAsFixed(0)}',
                ),
                _SumCell(
                  'মোট মিল',
                  '$_totalMeals',
                ),
                _SumCell(
                  'রেট',
                  '৳${_mealRate.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── LIST ────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _balances.length,
                    itemBuilder: (_, i) {
                      return _buildBalanceCard(_balances[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── BALANCE CARD ─────────────────────
  Widget _buildBalanceCard(MemberBalance b) {
    final pct =
        _totalCost > 0 ? (b.marketPaid / _totalCost).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _GradientAvatar(name: b.name, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${b.totalMeals} মিল',
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
                    b.isPositive
                        ? '+৳${b.balance.toStringAsFixed(0)}'
                        : '-৳${(-b.balance).toStringAsFixed(0)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: b.isPositive
                          ? const Color(0xFF065F46)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: b.isPositive
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      b.isPositive ? 'উদ্বৃত্ত' : 'বকেয়া',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: b.isPositive
                            ? const Color(0xFF065F46)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(
                b.isPositive
                    ? const Color(0xFF065F46)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'দিয়েছে: ৳${b.marketPaid.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                'খেয়েছে: ৳${b.mealOwe.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SUM CELL ─────────────────────────
class _SumCell extends StatelessWidget {
  final String label, value;

  const _SumCell(this.label, this.value);

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ── GRADIENT AVATAR ──────────────────────
class _GradientAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _GradientAvatar({
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final idx = name.codeUnitAt(0) % 4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppTheme.avatarGrads[idx],
        ),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
