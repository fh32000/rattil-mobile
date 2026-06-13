import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get arabicTextTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 40,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
