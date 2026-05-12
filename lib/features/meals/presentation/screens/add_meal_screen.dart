import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';

import '../../../../app/app_theme.dart';

import '../bloc/meal_bloc.dart';
import '../bloc/meal_event.dart';
import '../bloc/meal_state.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _State();
}

class _State extends State<AddMealScreen> {
  DateTime _date = DateTime.now();

  final Map<String, int> _counts = {};

  String get _dateStr {
    final m = _date.month.toString().padLeft(2, '0');

    final d = _date.day.toString().padLeft(2, '0');

    return '${_date.year}-$m-$d';
  }

  void _save() {
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;

    context.read<MealBloc>().add(
      SaveMealsRequested(
        messId: auth.user.messId!,
        date: _dateStr,
        counts: Map.from(_counts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = (context.watch<MessBloc>().state as MessLoaded).members;

    for (final m in members) {
      _counts.putIfAbsent(m.uid, () => 0);
    }

    return BlocListener<MealBloc, MealState>(
      listener: (ctx, state) {
        if (state is MealSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('মিল সেভ হয়েছে ✓'),
              backgroundColor: Colors.green,
            ),
          );

          ctx.pop();
        }

        if (state is MealError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.msg), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FDF4),
        body: Column(
          children: [
            // ── HEADER ───────────────────────
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.gradTeal),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'মিল যোগ করো 🍽️',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMMM yyyy').format(_date),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BlocBuilder<MealBloc, MealState>(
                            builder: (_, state) {
                              return GestureDetector(
                                onTap: state is MealSaving ? null : _save,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    state is MealSaving
                                        ? 'সেভ হচ্ছে...'
                                        : 'সেভ করো',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // DATE PICKER
                      GestureDetector(
                        onTap: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );

                          if (p != null) {
                            setState(() => _date = p);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('dd MMMM yyyy').format(_date),
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── MEMBER LIST ──────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'প্রতি সদস্যের মিল',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...members.map((m) {
                    return _memberRow(m);
                  }),

                  const SizedBox(height: 16),

                  // TOTAL
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradTeal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'আজকের মোট মিল',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _counts.values.fold(0, (a, b) => a + b).toString(),
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MEMBER ROW ─────────────────────────
  Widget _memberRow(dynamic m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDCFCE7),
            child: Text(
              m.name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              m.name,
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if ((_counts[m.uid] ?? 0) > 0) {
                  _counts[m.uid] = _counts[m.uid]! - 1;
                }
              });
            },
            icon: const Icon(Icons.remove),
          ),
          Text(
            '${_counts[m.uid] ?? 0}',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _counts[m.uid] = (_counts[m.uid] ?? 0) + 1;
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
