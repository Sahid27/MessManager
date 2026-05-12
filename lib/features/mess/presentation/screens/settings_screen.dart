import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/mess_bloc.dart';
import '../bloc/mess_event.dart';
import '../bloc/mess_state.dart';
import '../../domain/entities/member.dart';
import '../../data/repos/mess_repo_impl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthBloc>().state as AuthAuthenticated;
    final state = context.watch<MessBloc>().state;
    if (state is! MessLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final me = state.members.firstWhere((m) => m.uid == auth.user.uid,
      orElse: () => state.members.first);

    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(children: [
        // Profile card
        Container(margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            CircleAvatar(radius: 30, backgroundColor: const Color(0xFF534AB7),
              child: Text(auth.user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600))),
            const SizedBox(height: 10),
            Text(auth.user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(auth.user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF534AB7), borderRadius: BorderRadius.circular(20)),
              child: Text(me.isManager ? 'ম্যানেজার — ${state.mess.name}' : 'সদস্য — ${state.mess.name}',
                style: const TextStyle(color: Colors.white, fontSize: 11))),
          ])),
        // Manager handover (only manager sees)
        if (me.isManager) ...[
          const Padding(padding: EdgeInsets.fromLTRB(16,0,16,6),
            child: Text('ম্যানেজার পরিবর্তন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey))),
          ...state.members
            .where((m) => !m.isManager)
            .map((m) => ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFFEEEDFE),
                child: Text(m.name[0], style: const TextStyle(color: Color(0xFF534AB7)))),
              title: Text(m.name),
              subtitle: const Text('এই সদস্যকে ম্যানেজার বানাও'),
              trailing: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('নিশ্চিত করো'),
                      content: Text('${m.name} কে ম্যানেজার বানাবে?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ')),
                      ]));
                  if (confirm == true && context.mounted) {
                    await MessRepoImpl().handoverManager(state.mess.id, me.uid, m.uid);
                    if (context.mounted) context.read<MessBloc>().add(LoadMembersRequested(state.mess.id));
                  }
                },
                child: const Text('বানাও')),
            )),
          const Divider(),
        ],
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => context.read<AuthBloc>().add(LogoutRequested())),
      ]),
    );
  }
}