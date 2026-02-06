import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light theme
  static const Color primaryLight = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFFFF6B6B);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color successLight = Color(0xFF7BC47F);
  static const Color warningLight = Color(0xFFFFBE76);
  
  // Dark theme
  static const Color primaryDark = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFFFF6B6B);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);
  static const Color successDark = Color(0xFF7BC47F);
  static const Color warningDark = Color(0xFFFFBE76);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.secondaryLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: _textTheme(AppColors.textLight, AppColors.textSecondaryLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      error: AppColors.secondaryDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: _textTheme(AppColors.textDark, AppColors.textSecondaryDark),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}
