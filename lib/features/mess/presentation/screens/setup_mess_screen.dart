import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/mess_bloc.dart';
import '../bloc/mess_event.dart';
import '../bloc/mess_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SetupMessScreen extends StatefulWidget {
  const SetupMessScreen({super.key});

  @override
  State<SetupMessScreen> createState() => _SetupMessScreenState();
}

class _SetupMessScreenState extends State<SetupMessScreen> {
  final _nameCtrl  = TextEditingController();
  final _codeCtrl  = TextEditingController();
  final _nameForm  = GlobalKey<FormState>();
  final _codeForm  = GlobalKey<FormState>();
  bool _creatingMess = false; // true = create, false = join

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _createMess() {
    if (!_nameForm.currentState!.validate()) return;
    final authState =
        context.read<AuthBloc>().state as AuthAuthenticated;
    context.read<MessBloc>().add(
      CreateMessRequested(
        name:        _nameCtrl.text.trim(),
        creatorUid:  authState.user.uid,
        creatorName: authState.user.name,
      ),
    );
  }

  void _joinMess() {
    if (!_codeForm.currentState!.validate()) return;
    final authState =
        context.read<AuthBloc>().state as AuthAuthenticated;
    context.read<MessBloc>().add(
      JoinMessRequested(
        code: _codeCtrl.text.trim().toUpperCase(),
        uid:  authState.user.uid,
        name: authState.user.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessBloc, MessState>(
      listener: (ctx, state) {
        if (state is MessLoaded) {
          // সফল হলে Dashboard এ যাও
          ctx.go('/dashboard');
        }
        if (state is MessError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.msg),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Header ──────────────────────────────
                const Text(
                  'মেস সেটআপ করো',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'নতুন মেস তৈরি করো অথবা কোড দিয়ে যোগ দাও',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),

                // ── CREATE MESS CARD ────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFAFA9EC),
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _nameForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Title
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.add_home_work_outlined,
                            color: Colors.white, size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'নতুন মেস তৈরি করো',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C3489),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'শুরু করো এবং সদস্যদের আমন্ত্রণ দাও',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF534AB7),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Mess name input
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'মেসের নাম',
                            hintText: 'যেমন: Dreamer Mess',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'মেসের নাম দাও';
                            if (v.trim().length < 3)
                              return 'কমপক্ষে ৩ অক্ষর দাও';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Create button
                        BlocBuilder<MessBloc, MessState>(
                          builder: (_, state) {
                            final loading = state is MessLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: loading ? null : _createMess,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                ),
                                child: loading
                                  ? const SizedBox(
                                      height: 18, width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ))
                                  : const Text('মেস তৈরি করো'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Divider ─────────────────────────────
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'অথবা বিদ্যমান মেসে যোগ দাও',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ]),

                const SizedBox(height: 20),

                // ── JOIN MESS CARD ───────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _codeForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ইনভাইট কোড দিয়ে যোগ দাও',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _codeCtrl,
                          textCapitalization:
                              TextCapitalization.characters,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: '৬ ডিজিটের কোড',
                            hintText: 'যেমন: XK29AB',
                            counterText: '',
                            prefixIcon: const Icon(
                              Icons.vpn_key_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'কোড দাও';
                            if (v.trim().length != 6)
                              return 'কোড ঠিক ৬ ডিজিটের হতে হবে';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<MessBloc, MessState>(
                          builder: (_, state) {
                            final loading = state is MessLoading;
                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: loading ? null : _joinMess,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                ),
                                child: loading
                                  ? const SizedBox(
                                      height: 18, width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                  : const Text('মেসে যোগ দাও'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Logout link ─────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        LogoutRequested());
                    },
                    child: Text(
                      'অন্য account দিয়ে login করো',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}