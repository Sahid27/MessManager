import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _State();
}
class _State extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF534AB7),
      body: FadeTransition(
        opacity: _fade,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 72, color: Colors.white),
              SizedBox(height: 16),
              Text('MessManager', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
              SizedBox(height: 8),
              Text('মেস ম্যানেজমেন্ট সহজ করো', style: TextStyle(
                fontSize: 14, color: Colors.white70)),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}