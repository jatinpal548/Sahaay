import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SAHAAY App Theme
/// Soft, calming colors with gentle animations
class AppTheme {
  // Soft pastel color palette
  static const Color softPeach = Color(0xFFFFE5D9);
  static const Color softBeige = Color(0xFFF5F1EB);
  static const Color pastelTeal = Color(0xFFB8E6E6);
  static const Color mutedOrange = Color(0xFFFFD4A3);
  static const Color softGreen = Color(0xFFC8E6C9);
  static const Color softRed = Color(0xFFFFB3BA);
  static const Color softBlue = Color(0xFFB3D9FF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF4A4A4A);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textLight = Color(0xFF9A9A9A);
  
  // Gradient colors for backgrounds
  static const List<Color> gradientStart = [softPeach, softBeige];
  static const List<Color> gradientEnd = [pastelTeal, softBeige];
  
  // Stress level colors (soft, never harsh)
  static Color getStressColor(int level) {
    if (level <= 3) return softGreen;
    if (level <= 6) return mutedOrange;
    return softRed;
  }
  
  // Get emoji based on stress level
  static String getStressEmoji(int level) {
    if (level <= 2) return '😌';
    if (level <= 5) return '😕';
    if (level <= 8) return '😣';
    return '😰';
  }
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: pastelTeal,
        secondary: mutedOrange,
        surface: softBeige,
        error: softRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: pastelTeal,
          foregroundColor: textPrimary,
        ),
      ),
    );
  }
  
  // Animation durations (slow and gentle)
  static const Duration slowAnimation = Duration(milliseconds: 800);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration fastAnimation = Duration(milliseconds: 300);
  
  // Animation curves (soft easing)
  static const Curve softCurve = Curves.easeInOut;
  static const Curve gentleCurve = Curves.easeOut;
}
