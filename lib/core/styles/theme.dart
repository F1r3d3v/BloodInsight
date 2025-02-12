import 'package:bloodinsight/core/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.spaceCadet,
      scaffoldBackgroundColor: AppColors.icterine,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.spaceCadet,
        onPrimary: AppColors.icterine,
        secondary: AppColors.steelBlue,
        onSecondary: Colors.white,
        error: AppColors.bittersweet,
        onError: Colors.white,
        surface: AppColors.icterine700,
        onSurface: AppColors.spaceCadet,
      ),
      highlightColor: AppColors.moonstone,
      textTheme: GoogleFonts.fredokaTextTheme().apply(
        bodyColor: AppColors.spaceCadet,
        displayColor: AppColors.spaceCadet,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.icterine,
        foregroundColor: AppColors.spaceCadet,
        elevation: 0,
      ),
    );
  }
}
