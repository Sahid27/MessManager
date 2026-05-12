import 'package:flutter/material.dart';

class AppTheme {
  static const gradPrimary = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradTeal = LinearGradient(
    colors: [Color(0xFF0F6E56), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradAmber = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradIndigo = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const avatarGrads = [
    [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    [Color(0xFF0F6E56), Color(0xFF10B981)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  ];
}