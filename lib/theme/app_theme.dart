import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette taken from `assets/design_mockups/`.
abstract final class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const primarySoft = Color(0xFFEEF0FF);
  static const background = Color(0xFFF8F9FB);
  static const surface = Colors.white;
  static const track = Color(0xFFF1F3F8);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF0F172A);
  static const textMuted = Color(0xFF4B5563);
  static const hint = Color(0xFF9CA3AF);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const dangerDark = Color(0xFF991B1B);
  static const warning = Color(0xFFF5B400);
  static const success = Color(0xFF00B87E);
  static const successSoft = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF065F46);

  /// Dark "Today's focus" banner, top-left to bottom-right.
  static const midnightGradient = [
    Color(0xFF090D19),
    Color(0xFF111532),
    Color(0xFF161A47),
  ];
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: GoogleFonts.manrope(
          color: AppColors.hint,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: GoogleFonts.manrope(
          color: AppColors.danger,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? AppColors.primary
              : AppColors.hint,
        ),
        suffixIconColor: AppColors.hint,
        border: outline(AppColors.border),
        enabledBorder: outline(AppColors.border),
        focusedBorder: outline(AppColors.primary, 1.6),
        errorBorder: outline(AppColors.danger, 1.2),
        focusedErrorBorder: outline(AppColors.danger, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(58),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
