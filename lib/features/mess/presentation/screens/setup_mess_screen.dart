import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/mess_bloc.dart';
import '../bloc/mess_event.dart';
import '../bloc/mess_state.dart';

class SetupMessScreen extends StatefulWidget {
  const SetupMessScreen({super.key});
  @override
  State<SetupMessScreen> createState() => _State();
}
class _State extends State<SetupMessScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); _codeCtrl.dispose(); super.dispose(); }

  void _createMess() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মেসের নাম দাও'), backgroundColor: Colors.orange));
      return;
    }
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    context.read<MessBloc>().add(CreateMessRequested(
      name: _nameCtrl.text.trim(),
      creatorUid: auth.user.uid,
      creatorName: auth.user.name));
  }

  void _joinMess() {
    if (_codeCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('৬ ডিজিটের কোড দাও'), backgroundColor: Colors.orange));
      return;
    }
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    context.read<MessBloc>().add(JoinMessRequested(
      code: _codeCtrl.text.trim().toUpperCase(),
      uid: auth.user.uid, name: auth.user.name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessBloc, MessState>(
      listener: (ctx, state) {
        if (state is MessLoaded) ctx.go('/dashboard');
        if (state is MessError) ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(state.msg), backgroundColor: Colors.red.shade700));
      },
      builder: (ctx, state) {
        final loading = state is MessLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              const Text('মেস সেটআপ করো', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('নতুন মেস তৈরি করো অথবা কোড দিয়ে যোগ দাও',
                style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              // CREATE CARD
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFAFA9EC))),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('নতুন মেস তৈরি করো', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3C3489))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'মেসের নাম লেখো',
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _createMess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF534AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      child: loading
                        ? const SizedBox(height: 18, width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('মেস তৈরি করো'))),
                ])),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('অথবা', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),
              // JOIN CARD
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('কোড দিয়ে যোগ দাও', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: '৬ ডিজিটের কোড',
                      counterText: '',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity,
                    child: OutlinedButton(
                      onPressed: loading ? null : _joinMess,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF534AB7),
                        side: const BorderSide(color: Color(0xFF534AB7)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      child: const Text('মেসে যোগ দাও'))),
                ])),
              const SizedBox(height: 16),
              Center(child: TextButton(
                onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                child: Text('অন্য account দিয়ে login করো',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)))),
            ]),
          )),
        );
      },
    );
  }
}