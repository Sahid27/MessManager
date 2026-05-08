// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // প্রাইমারি রং (purple)
  static const primary = Color(0xFF534AB7);
  static const primaryLight = Color(0xFFEEEDFE);
  static const primaryDark = Color(0xFF3C3489);

  // Status রং
  static const success = Color(0xFF1D9E75); // paid
  static const warning = Color(0xFFBA7517); // partial
  static const danger = Color(0xFFE24B4A); // due

  // Text রং
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textHint = Color(0xFFAAAAAA);

  // Member avatar রং (৬ জনের জন্য)
  static const avatarColors = [
    Color(0xFFEEEDFE), // Raju - purple
    Color(0xFFE1F5EE), // Rana - teal
    Color(0xFFFAEEDA), // Shahid - amber
    Color(0xFFFBEAF0), // Polas - pink
    Color(0xFFF1EFE8), // Nayeem - gray
    Color(0xFFE6F1FB), // Sourav - blue
  ];
}