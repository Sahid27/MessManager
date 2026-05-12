import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────
  static const primary     = Color(0xFF7C3AED);
  static const primaryDark = Color(0xFF2D1B69);
  static const primaryDeep = Color(0xFF1a0533);
  static const teal        = Color(0xFF065F46);
  static const tealBright  = Color(0xFF047857);
  static const amber       = Color(0xFFD97706);
  static const indigo      = Color(0xFF4338CA);
  static const danger      = Color(0xFFDC2626);

  // ── Gradients ─────────────────────────
  static const gradPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF1a0533), Color(0xFF2D1B69), Color(0xFF7C3AED)],
  );
  static const gradTeal = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
  );
  static const gradAmber = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFD97706)],
  );
  static const gradIndigo = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
  );

  // ── Member Avatar Colors ───────────────
  static const avatarGrads = [
    [Color(0xFF7C3AED), Color(0xFFA855F7)],
    [Color(0xFF065F46), Color(0xFF10B981)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
    [Color(0xFFDC2626), Color(0xFFF87171)],
    [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
    [Color(0xFF0D9488), Color(0xFF14B8A6)],
  ];

  // ── Typography ────────────────────────
  static ThemeData get theme {
    final base = ThemeData(
      colorSchemeSeed: primary, useMaterial3: true);
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
                   base.textTheme),
    );
  }
}

// ── Shared Gradient Widget ─────────────
class GradientHeader extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;
  const GradientHeader({
    required this.gradient,
    required this.child, super.key});
  @override
  Widget build(BuildContext _) => Container(
    decoration: BoxDecoration(gradient: gradient),
    child: child);
}