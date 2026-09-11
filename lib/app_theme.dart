import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF8F7FC);
  static const backgroundDark = Color(0xFF0D0D12);
  static const card = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1A1A26);
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF8E8E93);
  static const textDark = Color(0xFFF5F5F7);
  static const textDarkSecondary = Color(0xFF6E6E73);
  static const accent = Color(0xFF6750A4);
  static const accentLight = Color(0xFFEDE7F6);
  static const border = Color(0xFFF0F0F5);
  static const borderDark = Color(0xFF2C2C34);

  static const calculatorIcon = Color(0xFF6750A4);
  static const clockIcon = Color(0xFF34C759);
  static const flashlightIcon = Color(0xFFFF9F0A);
  static const todoIcon = Color(0xFF007AFF);
  static const stopwatchIcon = Color(0xFFFF3B30);
  static const websearchIcon = Color(0xFF5AC8FA);

  static const calculatorBg = Color(0xFFF3EDFF);
  static const clockBg = Color(0xFFE8F8EC);
  static const flashlightBg = Color(0xFFFFF5E6);
  static const todoBg = Color(0xFFE6F2FF);
  static const stopwatchBg = Color(0xFFFFECEB);
  static const websearchBg = Color(0xFFE6F7FF);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF1C1B1F).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardPressed = [
    BoxShadow(
      color: const Color(0xFF1C1B1F).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: const Color(0xFF1C1B1F).withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];
}

class AppRadius {
  AppRadius._();

  static const card = BorderRadius.all(Radius.circular(20));
  static const button = BorderRadius.all(Radius.circular(14));
  static const input = BorderRadius.all(Radius.circular(14));
  static const icon = BorderRadius.all(Radius.circular(14));
  static const chip = BorderRadius.all(Radius.circular(10));
}

class RongTheme {
  RongTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorSchemeSeed: AppColors.accent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorSchemeSeed: AppColors.accent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
