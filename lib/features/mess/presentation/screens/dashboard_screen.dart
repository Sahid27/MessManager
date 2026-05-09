import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Screen খুললেই member list load করো
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final messId = authState.user.messId;
        if (messId != null) {

  Future.delayed(
    const Duration(milliseconds: 500),
    () {

      context.read<MessBloc>().add(
        LoadMembersRequested(messId),
      );

    },
  );

}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessBloc, MessState>(
      builder: (ctx, messState) {

        // লোড হচ্ছে
        if (messState is MessInitial ||
            messState is MessLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('মেসের তথ্য লোড হচ্ছে...',
                    style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // Error হলে
        if (messState is MessError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                    size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(messState.msg),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final authState =
                        context.read<AuthBloc>().state
                          as AuthAuthenticated;
                      context.read<MessBloc>().add(
                        LoadMembersRequested(
                          authState.user.messId!));
                    },
                    child: const Text('আবার চেষ্টা করো'),
                  ),
                ],
              ),
            ),
          );
        }

        // Data লোড হয়েছে
        final state   = messState as MessLoaded;
        final mess    = state.mess;
        final members = state.members;
        final authUser = (context.read<AuthBloc>().state
                          as AuthAuthenticated).user;
        final me = members.firstWhere(
          (m) => m.uid == authUser.uid,
          orElse: () => members.first,
        );
        final isManager = me.isManager;

        return Scaffold(
          body: Column(
            children: [

              // ── Purple Header ──────────────────────
              Container(
                color: AppColors.primary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 10, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Text(mess.name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12)),
                              Text(
                                'স্বাগতম, ${authUser.name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Spacer(),
                          // Avatar
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Text(
                              authUser.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        // Manager badge + Invite code
                        Row(children: [
                          if (isManager)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20)),
                              child: Row(children: const [
                                Icon(Icons.shield_outlined,
                                  size: 13, color: Colors.white),
                                SizedBox(width: 4),
                                Text('তুমি ম্যানেজার',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11)),
                              ]),
                            ),
                          const Spacer(),
                          // Invite code — tap করলে copy হবে
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                text: mess.inviteCode));
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'কোড copy হয়েছে!'),
                                  duration: Duration(seconds: 2),
                                ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(20)),
                              child: Row(children: [
                                Text(
                                  'কোড: ${mess.inviteCode}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11)),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy,
                                  size: 12, color: Colors.white54),
                              ]),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              // ── White Body ─────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Quick action grid ────────────────
                      const Text(
                        'দ্রুত প্রবেশ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                        children: [
                          _ActionCard(
                            label: 'মিল শিট',
                            icon: Icons.calendar_month_outlined,
                            color: const Color(0xFFEEEDFE),
                            iconColor: AppColors.primary,
                            onTap: () => ctx.push('/meals'),
                          ),
                          _ActionCard(
                            label: 'খরচের ইতিহাস',
                            icon: Icons.receipt_long_outlined,
                            color: const Color(0xFFE1F5EE),
                            iconColor: const Color(0xFF0F6E56),
                            onTap: () => ctx.push('/costs'),
                          ),
                          _ActionCard(
                            label: 'সারসংক্ষেপ',
                            icon: Icons.pie_chart_outline,
                            color: const Color(0xFFFAEEDA),
                            iconColor: const Color(0xFF854F0B),
                            onTap: () => ctx.push('/summary'),
                          ),
                          _ActionCard(
                            label: 'বাসার খরচ',
                            icon: Icons.home_outlined,
                            color: const Color(0xFFE6F1FB),
                            iconColor: const Color(0xFF0C447C),
                            onTap: () => ctx.push('/house-costs'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Members list ─────────────────────
                      Row(children: [
                        const Text(
                          'সদস্যরা',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEDFE),
                            borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            '${members.length} জন',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                        ),
                      ]),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const
                            NeverScrollableScrollPhysics(),
                          itemCount: members.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade100),
                          itemBuilder: (_, i) {
                            final m = members[i];
                            return _MemberTile(
                              member: m,
                              isMe: m.uid == authUser.uid,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Logout ───────────────────────────
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout,
                            size: 16, color: Colors.red),
                          label: const Text('Logout',
                            style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              LogoutRequested());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Navigation ──────────────────
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) {
              setState(() => _currentIndex = i);
              switch (i) {
                case 0: break; // Home — এখানেই আছি
                case 1: ctx.push('/meals'); break;
                case 2: ctx.push('/summary'); break;
                case 3: ctx.push('/settings'); break;
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
}

// ── Helper Widgets ─────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;
  final Color    iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MessMember member;
  final bool       isMe;

  const _MemberTile({
    required this.member,
    required this.isMe,
  });

  // Member দের জন্য আলাদা রং
  static const _colors = [
    Color(0xFFEEEDFE), Color(0xFFE1F5EE),
    Color(0xFFFAEEDA), Color(0xFFFBEAF0),
    Color(0xFFE6F1FB), Color(0xFFF1EFE8),
  ];
  static const _textColors = [
    Color(0xFF534AB7), Color(0xFF085041),
    Color(0xFF633806), Color(0xFF72243E),
    Color(0xFF0C447C), Color(0xFF5F5E5A),
  ];

  @override
  Widget build(BuildContext _) {
    final idx = member.name.codeUnitAt(0) % _colors.length;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _colors[idx],
        child: Text(
          member.name[0].toUpperCase(),
          style: TextStyle(
            color: _textColors[idx],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Row(children: [
        Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (isMe) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8)),
            child: const Text('তুমি',
              style: TextStyle(
                fontSize: 10, color: Colors.grey)),
          ),
        ],
      ]),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 3),
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