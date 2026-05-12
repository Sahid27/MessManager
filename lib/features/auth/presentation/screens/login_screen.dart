import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _State();
}

class _State extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      LoginRequested(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      ),
    );
  }

  void _listener(BuildContext ctx, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _listener,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [

            // ── Gradient Hero ─────────────────
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: AppTheme.gradPrimary,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    24,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '👋 স্বাগতম আবার',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'তোমার মেসে\nসাইন ইন করো',
                        style:
                            GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [

                      _InputField(
                        ctrl: _email,
                        label: 'ইমেইল',
                        icon:
                            Icons.email_outlined,
                        type:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 12),

                      _InputField(
                        ctrl: _pass,
                        label: 'পাসওয়ার্ড',
                        icon:
                            Icons.lock_outline,
                        obscure: true,
                      ),

                      const SizedBox(height: 24),

                      BlocBuilder<AuthBloc,
                          AuthState>(
                        builder: (_, state) {
                          return _GradientButton(
                            label:
                                state is AuthLoading
                                    ? 'লোড হচ্ছে...'
                                    : 'সাইন ইন করো',
                            gradient:
                                AppTheme.gradPrimary,
                            onTap:
                                state is AuthLoading
                                    ? () {}
                                    : _submit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Styled Input ──────────────
class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? type;

  const _InputField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.type,
  });

  @override
  Widget build(BuildContext _) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 13),

      validator: (v) {
        if (v == null || v.isEmpty) {
          return '$label দাও';
        }

        if (label == 'ইমেইল' &&
            !RegExp(
              r'^[^@]+@[^@]+\.[^@]+',
            ).hasMatch(v)) {
          return 'সঠিক ইমেইল দাও';
        }

        if (label == 'পাসওয়ার্ড' &&
            v.length < 6) {
          return 'কমপক্ষে ৬ অক্ষর দাও';
        }

        return null;
      },

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(
          icon,
          color: AppTheme.primary,
        ),

        filled: true,
        fillColor: const Color(0xFFF8F6FF),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE9E4FF),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE9E4FF),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ── Reusable Gradient Button ───────────
class _GradientButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,

        decoration: BoxDecoration(
          gradient: gradient,

          borderRadius:
              BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color: gradient.colors.last
                  .withOpacity(.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Center(
          child: Text(
            label,
            style:
                GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme ──────────────────────────────
class AppTheme {
  static const primary = Color(0xFF6C63FF);

  static const gradPrimary = LinearGradient(
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF8E85FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}