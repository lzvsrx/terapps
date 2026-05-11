import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgA = Color(0xFF05060A);
  static const Color bgB = Color(0xFF0A0F1F);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color neonPurple2 = Color(0xFFC084FC);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color chrome = Color(0xFFE5E7EB);
  static const Color chromeDark = Color(0xFFC0C7D1);

  static ThemeData buildTheme({required bool highContrast}) {
    final textTheme = GoogleFonts.exo2TextTheme().apply(
      bodyColor: highContrast ? Colors.white : chrome,
      displayColor: highContrast ? Colors.white : chrome,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgA,
      textTheme: textTheme.copyWith(
        headlineSmall: GoogleFonts.orbitron(
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: highContrast ? Colors.white : chrome,
        ),
        titleMedium: GoogleFonts.rajdhani(
          letterSpacing: 1.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: highContrast ? 0.12 : 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: neonBlue.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonCyan, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
