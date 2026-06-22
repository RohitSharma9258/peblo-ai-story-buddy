import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kid-friendly theme colors and styles for Peblo AI Story Buddy.
class AppTheme {
  // Custom Color Palette - Curated pastel and bright playful colors
  static const Color primaryColor = Color(0xFFFF6F59); // Friendly coral
  static const Color secondaryColor = Color(0xFF4ECDC4); // Mint teal
  static const Color accentColor = Color(0xFFFFD166); // Sun yellow
  static const Color correctColor = Color(0xFF6BCB77); // Success green
  static const Color wrongColor = Color(0xFFFF6B6B); // Soft error red
  static const Color backgroundColor = Color(0xFFFFFDF6); // Cream background
  static const Color cardColor = Color(0xFFFFFFFF); // White for cards
  static const Color textColor = Color(0xFF2C3E50); // Deep charcoal
  static const Color textSecondaryColor = Color(0xFF7F8C8D); // Soft grey

  /// Returns the overall ThemeData configured for children.
  static ThemeData get kidTheme {
    final textTheme = GoogleFonts.fredokaTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: cardColor,
        error: wrongColor,
      ),
      textTheme: textTheme,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 6,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(
            color: Color(0xFFF0EAE1),
            width: 2.0,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 6,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: const BorderSide(
              color: Colors.white,
              width: 3,
            ),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 28,
      ),
    );
  }

  /// Text style for headings / titles
  static TextStyle get headingStyle => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        shadows: [
          const Shadow(
            offset: Offset(1, 1),
            blurRadius: 2.0,
            color: Color(0x20000000),
          ),
        ],
      );

  /// Text style for story content
  static TextStyle get storyStyle => GoogleFonts.fredoka(
        fontSize: 22,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: textColor,
      );

  /// Text style for quiz questions
  static TextStyle get questionStyle => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  /// Text style for buttons and choices
  static TextStyle get optionStyle => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
      );
}
