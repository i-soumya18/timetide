import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF219EBC);
  static const Color primaryLight = Color(0xFF8ECAE6);
  static const Color primaryDark = Color(0xFF1A7A94);

  // Secondary/accent colors
  static const Color secondary = Color(0xFF8ECAE6);
  static const Color accent = Color(0xFFFFB703);
  static const Color accentLight = Color(0xFFFFC833);
  static const Color accentDark = Color(0xFFE6A403);

  // Background colors
  static const Color backgroundLight = Color(0xFFFCFCFC);
  static const Color backgroundLightSecondary = Color(0xFFF5F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDarkSecondary = Color(0xFF222222);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF555B6E);
  static const Color textLight = Color(0xFFF7FAFC);
  static const Color textDark = Color(0xFF121212);

  // Functional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Category colors (with slightly refined tones)
  static const Color categoryWork = Color(0xFFFFB703);
  static const Color categoryHealth = Color(0xFFF72585);
  static const Color categoryErrands = Color(0xFF7209B7);
  static const Color categoryPersonal = Color(0xFF219EBC);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card/Container colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x1AFFFFFF);

  // Gradient colors
  static List<Color> primaryGradient = [primary, primaryLight];
  static List<Color> accentGradient = [accent, accentLight];
}