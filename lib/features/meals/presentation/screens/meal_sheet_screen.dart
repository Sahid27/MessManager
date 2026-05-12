import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_guard.dart';

import '../../../../core/widgets/gradient_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';

import '../bloc/meal_bloc.dart';
import '../bloc/meal_event.dart';
import '../bloc/meal_state.dart';

class MealSheetScreen extends StatefulWidget {
  const MealSheetScreen({super.key});

  @override
  State<MealSheetScreen> createState() =>
      _State();
}

class _State extends State<MealSheetScreen> {

  DateTime _month = DateTime.now();

  String get _monthKey {

    final m =
        _month.month.toString().padLeft(2, '0');

    return '${_month.year}-$m';
  }

  String get _monthDisplay {

    return DateFormat(
      'MMMM yyyy',
    ).format(_month);
  }

  String get _messId {

    return (context.read<AuthBloc>().state
            as AuthAuthenticated)
        .user
        .messId!;
  }

  double get totalCollection => 3563;

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      context.read<MealBloc>().add(
            LoadMealsRequested(
              messId: _messId,
              month: _monthKey,
            ),
          );
    });
  }

  void _changeMonth(int delta) {

    setState(() {

      _month = DateTime(
        _month.year,
        _month.month + delta,
      );
    });

    context.read<MealBloc>().add(
          LoadMealsRequested(
            messId: _messId,
            month: _monthKey,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {

    final members =
        (context.watch<MessBloc>().state
                as MessLoaded)
            .members;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF0FDF4),

      body: Column(
        children: [

          // ── Gradient Header ────────────────
          Container(

            decoration: const BoxDecoration(
              gradient: AppTheme.gradTeal,
            ),

            child: SafeArea(

              bottom: false,

              child: Padding(

                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  14,
                ),

                child: Column(
                  children: [

                    Row(
                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              'মিল শিট 📅',

                              style:
                                  GoogleFonts
                                      .spaceGrotesk(
                                color:
                                    Colors.white,

                                fontSize: 18,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            BlocBuilder<
                                MealBloc,
                                MealState>(
                              builder:
                                  (_, state) {

                                return Text(

                                  state
                                          is MealLoaded
                                      ? '$_monthKey — ${state.totalMeals} মোট মিল'
                                      : _monthKey,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .white60,

                                    fontSize:
                                        10,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const Spacer(),

                        RoleGuard(
                          child:
                              GestureDetector(

                            onTap: () {

                              context.push(
                                '/meals/add',
                              );
                            },

                            child: Container(

                              width: 36,
                              height: 36,

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white
                                    .withOpacity(.2),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  50,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons.add,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Month selector
                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        _CircleBtn(
                          icon:
                              Icons.chevron_left,

                          onTap: () =>
                              _changeMonth(-1),
                        ),

                        Text(
                          _monthDisplay,

                          style:
                              GoogleFonts
                                  .spaceGrotesk(
                            color:
                                Colors.white,

                            fontSize: 13,

                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        _CircleBtn(
                          icon:
                              Icons.chevron_right,

                          onTap: () =>
                              _changeMonth(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats Row ──────────────────────
          BlocBuilder<MealBloc, MealState>(
            builder: (_, state) {

              if (state is! MealLoaded) {

                return const SizedBox();
              }

              return Container(

                color: Colors.white,

                padding:
                    const EdgeInsets.all(10),

                child: Row(
                  children: [

                    _MiniStat(
                      'মোট মিল',
                      state.totalMeals
                          .toString(),

                      const Color(
                        0xFF065F46,
                      ),

                      const Color(
                        0xFFECFDF5,
                      ),
                    ),

                    const SizedBox(width: 8),

                    _MiniStat(
                      'সংগৃহীত',
                      '৳${totalCollection.toStringAsFixed(0)}',

                      const Color(
                        0xFF4338CA,
                      ),

                      const Color(
                        0xFFEDE9FE,
                      ),
                    ),

                    const SizedBox(width: 8),

                    _MiniStat(
                      'মিল রেট',
                      '৳${state.mealRate.toStringAsFixed(2)}',

                      const Color(
                        0xFFD97706,
                      ),

                      const Color(
                        0xFFFEF9C3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── DataTable ──────────────────────
          Expanded(
            child: BlocBuilder<
                MealBloc,
                MealState>(
              builder: (_, state) {

                if (state is MealLoading ||
                    state is MealInitial) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (state is MealError) {

                  return Center(
                    child: Text(state.msg),
                  );
                }

                if (state is! MealLoaded) {

                  return const SizedBox();
                }

                if (state.entries.isEmpty) {

                  return const Center(
                    child: Text(
                      'এই মাসে কোনো মিল নেই',

                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(

                  scrollDirection:
                      Axis.horizontal,

                  child: SingleChildScrollView(

                    child: DataTable(

                      headingRowColor:
                          MaterialStateProperty.all(
                        const Color(0xFF065F46),
                      ),

                      headingTextStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),

                      columns: [

                        const DataColumn(
                          label: Text('তারিখ'),
                        ),

                        ...members.map(
                          (m) => DataColumn(
                            label: Text(m.name),
                          ),
                        ),

                        const DataColumn(
                          label: Text('মোট'),
                        ),
                      ],

                      rows: [

                        ...state.entries.map(
                          (entry) {

                            return DataRow(
                              cells: [

                                DataCell(

                                  Text(

                                    DateFormat(
                                      'dd',
                                    ).format(
                                      DateTime.parse(
                                        entry.date,
                                      ),
                                    ),
                                  ),
                                ),

                                ...members.map(
                                  (m) {

                                    return DataCell(
                                      Text(
                                        entry
                                            .mealFor(
                                              m.uid,
                                            )
                                            .toString(),
                                      ),
                                    );
                                  },
                                ),

                                DataCell(
                                  Text(

                                    entry
                                        .totalMeals
                                        .toString(),

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        DataRow(

                          color:
                              MaterialStateProperty
                                  .all(
                            const Color(
                              0xFFE1F5EE,
                            ),
                          ),

                          cells: [

                            const DataCell(
                              Text(
                                'মোট',

                                style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ),

                            ...members.map(
                              (m) {

                                final t =
                                    state.entries.fold(
                                  0,

                                  (s, e) =>
                                      s +
                                      e.mealFor(
                                        m.uid,
                                      ),
                                );

                                return DataCell(

                                  Text(

                                    t.toString(),

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                );
                              },
                            ),

                            DataCell(
                              Text(

                                state.totalMeals
                                    .toString(),

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w700,

                                  color: Color(
                                    0xFF065F46,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB ─────────────────────────────
      floatingActionButton: RoleGuard(

        child: Container(

          decoration: const BoxDecoration(

            gradient:
                AppTheme.gradTeal,

            shape: BoxShape.circle,

            boxShadow: [

              BoxShadow(
                color:
                    Color(0x66065F46),

                blurRadius: 20,

                offset: Offset(0, 8),
              ),
            ],
          ),

          child: FloatingActionButton(

            onPressed: () {

              context.push(
                '/meals/add',
              );
            },

            backgroundColor:
                Colors.transparent,

            elevation: 0,

            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {

  final String label;
  final String value;
  final Color fg;
  final Color bg;

  const _MiniStat(
    this.label,
    this.value,
    this.fg,
    this.bg,
  );

  @override
  Widget build(BuildContext context) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: bg,

          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(
          children: [

            Text(
              value,

              style:
                  GoogleFonts.spaceGrotesk(
                color: fg,

                fontSize: 16,

                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,

              style: TextStyle(
                color: fg.withOpacity(.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {

  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        width: 34,
        height: 34,

        decoration: BoxDecoration(
          color:
              Colors.white.withOpacity(.15),

          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AppTheme {

  static const gradTeal = LinearGradient(
    colors: [
      Color(0xFF065F46),
      Color(0xFF10B981),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}