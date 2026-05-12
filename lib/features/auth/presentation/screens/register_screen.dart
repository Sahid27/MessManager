import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _State();
}
class _State extends State<RegisterScreen> {
  final _form    = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure  = true;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context.read<AuthBloc>().add(RegisterRequested(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _pass.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('একাউন্ট তৈরি করো'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(key: _form, child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'পুরো নাম',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder()),
                validator: (v) =>
                  (v?.isEmpty ?? true) ? 'নাম দাও' : null),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ইমেইল ঠিকানা',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder()),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'ইমেইল দাও';
                  if (!v!.contains('@')) return 'সঠিক ইমেইল দাও';
                  return null;
                }),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'পাসওয়ার্ড',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure))),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'পাসওয়ার্ড দাও';
                  if (v!.length < 6) return 'কমপক্ষে ৬ অক্ষর দাও';
                  return null;
                }),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'পাসওয়ার্ড নিশ্চিত করো',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder()),
                validator: (v) =>
                  v != _pass.text ? 'পাসওয়ার্ড মিলছে না' : null),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) => FilledButton(
                  onPressed: state is AuthLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: state is AuthLoading
                    ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('একাউন্ট তৈরি করো', style: TextStyle(fontSize: 15)),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('আগেই একাউন্ট আছে? ',
                  style: TextStyle(color: Colors.grey.shade600)),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('সাইন ইন করো')),
              ]),
            ],
          )),
        ),
      ),
    );
  }
}