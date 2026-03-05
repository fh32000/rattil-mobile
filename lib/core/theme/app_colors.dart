import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette – deep teal inspired by Islamic geometric art
  static const Color primary = Color(0xFF0D4F4F);
  static const Color primaryLight = Color(0xFF1A7A7A);
  static const Color primaryDark = Color(0xFF083636);

  // Accent – warm gold
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE0C97A);

  // Surface / Background
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFFF7F5F0);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1F2940);
  static const Color cardLight = Color(0xFFF0EDE5);

  // Text
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);

  // Player
  static const Color playerBackground = Color(0xFF0F1626);
  static const Color progressActive = accent;
  static const Color progressInactive = Color(0xFF3A3A5C);

  // Status
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
}
