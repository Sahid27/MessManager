import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/gradient_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import '../bloc/mess_bloc.dart';
import '../bloc/mess_event.dart';
import '../bloc/mess_state.dart';

import '../../domain/entities/member.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _State();
}

class _State extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthBloc>().state;

      if (auth is AuthAuthenticated && auth.user.messId != null) {
        final ms = context.read<MessBloc>().state;

        if (ms is! MessLoaded) {
          context.read<MessBloc>().add(
                LoadMembersRequested(
                  auth.user.messId!,
                ),
              );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessBloc, MessState>(
      builder: (ctx, messState) {
        if (messState is MessInitial || messState is MessLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'মেসের তথ্য লোড হচ্ছে...',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (messState is MessError) {
          return Scaffold(
            body: Center(
              child: Text(messState.msg),
            ),
          );
        }

        final state = messState as MessLoaded;

        final auth = context.read<AuthBloc>().state as AuthAuthenticated;

        final me = state.members.isNotEmpty
            ? state.members.firstWhere(
                (m) => m.uid == auth.user.uid,
                orElse: () => state.members.first,
              )
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7FB),
          body: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'দ্রুত প্রবেশ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          _ActionCard(
                            label: 'মিল শিট',
                            emoji: '📅',
                            gradient: AppTheme.gradPrimary,
                            onTap: () => ctx.push('/meals'),
                          ),
                          _ActionCard(
                            label: 'খরচ ইতিহাস',
                            emoji: '🧾',
                            gradient: AppTheme.gradTeal,
                            onTap: () => ctx.push('/costs'),
                          ),
                          _ActionCard(
                            label: 'সারসংক্ষেপ',
                            emoji: '📊',
                            gradient: AppTheme.gradAmber,
                            onTap: () => ctx.push('/summary'),
                          ),
                          _ActionCard(
                            label: 'বাসার খরচ',
                            emoji: '🏠',
                            gradient: AppTheme.gradIndigo,
                            onTap: () => ctx.push('/house-costs'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            'সদস্যরা',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.members.length} জন',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF534AB7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.members.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                          itemBuilder: (_, i) {
                            return _MemberTile(
                              state.members[i],
                              state.members[i].uid == auth.user.uid,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 18,
                          ),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  LogoutRequested(),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (i) {
              switch (i) {
                case 1:
                  ctx.push('/meals');
                  break;

                case 2:
                  ctx.push('/summary');
                  break;

                case 3:
                  ctx.push('/settings');
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'হোম',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'মিল',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'সারসংক্ষেপ',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'সেটিংস',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(MessLoaded state) {
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
    final user = auth.user;

    final me = state.members.isNotEmpty
        ? state.members.firstWhere(
            (m) => m.uid == user.uid,
            orElse: () => state.members.first,
          )
        : null;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradPrimary,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.mess.name,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'স্বাগতম, ${user.name} 👋',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _GradientAvatar(
                    name: user.name,
                    size: 38,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (me != null && me.isManager)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(.15),
                      border: Border.all(
                        color: Colors.amber.withOpacity(.4),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '⚡ ',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          'তুমি এই মাসের ম্যানেজার',
                          style: TextStyle(
                            color: Color(0xFFFCD34D),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(.1),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: const [
                      _StatItem(
                        'মোট মিল',
                        '59',
                      ),
                      _Divider(),
                      _StatItem(
                        'সংগৃহীত',
                        '৳3,563',
                      ),
                      _Divider(),
                      _StatItem(
                        'মিল রেট',
                        '৳60.4',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(
    this.label,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      color: Colors.white12,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String emoji;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _GradientAvatar({
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppTheme.gradAmber,
        shape: BoxShape.circle,
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

class _MemberTile extends StatelessWidget {
  final MessMember member;
  final bool isMe;

  const _MemberTile(
    this.member,
    this.isMe,
  );

  static const _bg = [
    Color(0xFFEEEDFE),
    Color(0xFFE1F5EE),
    Color(0xFFFAEEDA),
    Color(0xFFFBEAF0),
    Color(0xFFE6F1FB),
    Color(0xFFF1EFE8),
  ];

  static const _fg = [
    Color(0xFF534AB7),
    Color(0xFF085041),
    Color(0xFF633806),
    Color(0xFF72243E),
    Color(0xFF0C447C),
    Color(0xFF5F5E5A),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = member.name.codeUnitAt(0) % 6;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _bg[idx],
        child: Text(
          member.name[0].toUpperCase(),
          style: TextStyle(
            color: _fg[idx],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            member.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'তুমি',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: member.isManager
              ? const Color(0xFFEEEDFE)
              : const Color(0xFFE1F5EE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          member.isManager ? 'ম্যানেজার' : 'সদস্য',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: member.isManager
                ? const Color(0xFF3C3489)
                : const Color(0xFF085041),
          ),
        ),
      ),
    );
  }
}

class AppTheme {
  static const gradPrimary = LinearGradient(
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF8B5CF6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradTeal = LinearGradient(
    colors: [
      Color(0xFF0EA5A4),
      Color(0xFF14B8A6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradAmber = LinearGradient(
    colors: [
      Color(0xFFF59E0B),
      Color(0xFFFBBF24),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradIndigo = LinearGradient(
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
