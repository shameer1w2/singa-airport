import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF141519); // Very dark gray/blue
  static const Color surface = Color(0xFF1E1F24);
  static const Color surfaceElevated = Color(0xFF2A2B31);
  static const Color surfaceCard = Color(0xFF141519);

  // Brand / Accent
  static const Color primary = Color(0xFFF4CE4F); // Yellow
  static const Color primaryLight = Color(0xFFF8E190);
  static const Color accentTicket = Color(0xFFEA5455); // Red for tickets
  static const Color accentCar = Color(0xFF82EA7A); // Green for car rent
  static const Color whiteCard = Color(0xFFFFFFFF);
  
  static const List<Color> primaryGradient = [Color(0xFFF4CE4F), Color(0xFFE0BB40)];
  static const Color accent = Color(0xFF6C63FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9898A6);
  static const Color textTertiary = Color(0xFF5C5C6E);

  // Dark text for cards
  static const Color textDark = Color(0xFF141519);

  // Status
  static const Color success = Color(0xFF82EA7A);
  static const Color warning = Color(0xFFFF9F43);
  static const Color error = Color(0xFFEA5455);
  static const Color info = Color(0xFF48CAE4);

  static const Color border = Color(0xFF2E2E3A);
  static const Color divider = Color(0xFF232330);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textTertiary, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        elevation: 0,
      ),
    );
  }
}
