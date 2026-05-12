import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientAvatar extends StatelessWidget {
  final String name;
  final double size;

  const GradientAvatar({
    super.key,
    required this.name,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final idx = name.codeUnitAt(0) % AppTheme.avatarGrads.length;
    final grad = AppTheme.avatarGrads[idx];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: grad,
        ),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}