import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bgPrimary = Color(0xFF000000);
  static const Color black50 = Color(0x80000000);
  static const Color cardBg = Color(0xFF070D08);
  static const Color cardBgElevated = Color(0xFF0C160E);
  static const Color cardBorder = Color(0xFF16301C);
  static const Color divider = Color(0xFF12261A);

  static const Color gold = Color(0xFFFFC940);
  static const Color goldLine = Color(0xFF6B5514);
  static const Color goldSoft = Color(0xFF1F1A08);

  static const Color greenPrimary = Color(0xFF39FF14);
  static const Color greenLine = Color(0x6639FF14);
  static const Color greenSoft = Color(0x1F39FF14);
  static const Color onGreen = Color(0xFF021A04);

  static const Color switchOff = Color(0xFF1A2A1F);

  static const Color textHint = Color(0xFF55695A);
  static const Color textPrimary = Color(0xFFEAFBEA);
  static const Color textSecondary = Color(0xFF8AA090);
  static const Color textSoft = Color(0xFFC9DDCF);
  static const Color textTertiary = Color(0xFF6F8577);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  AppTextStyles._();

  static const String fontDisplay = 'Biger';
  static const String fontBody = 'Small';

  static TextStyle display(
    double size, {
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.04,
  }) {
    return TextStyle(
      fontFamily: fontDisplay,
      fontSize: size,
      color: color,
      letterSpacing: size * letterSpacing,
      height: 1.15,
    );
  }

  static TextStyle body(
    double size, {
    Color color = AppColors.textSecondary,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontBody,
      fontSize: size,
      color: color,
      height: height,
    );
  }
}
