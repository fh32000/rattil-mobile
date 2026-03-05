import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get arabicTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
