import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginRequested(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.restaurant_menu,
                      color: Color(0xFF534AB7), size: 32),
                  ),
                  const SizedBox(height: 24),
                  const Text('স্বাগতম আবার',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('তোমার মেসে সাইন ইন করো',
                    style: TextStyle(
                      color: Colors.grey.shade600)),
                  const SizedBox(height: 32),
                  // Email field
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'ইমেইল ঠিকানা',
                      hintText: 'raju@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'ইমেইল দাও';
                      if (!v.contains('@'))
                        return 'সঠিক ইমেইল দাও';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'পাসওয়ার্ড',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                        onPressed: () =>
                          setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'পাসওয়ার্ড দাও';
                      if (v.length < 6)
                        return 'কমপক্ষে ৬ অক্ষর দাও';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Login button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (ctx, state) {
                      final loading = state is AuthLoading;
                      return FilledButton(
                        onPressed: loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14),
                          backgroundColor:
                            const Color(0xFF534AB7),
                        ),
                        child: loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                          : const Text('সাইন ইন করো',
                              style: TextStyle(fontSize: 15)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('একাউন্ট নেই? ',
                        style: TextStyle(
                          color: Colors.grey.shade600)),
                      TextButton(
                        onPressed: () =>
                          context.push('/register'),
                        child: const Text('এখানে রেজিস্টার করো'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}