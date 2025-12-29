import 'package:flutter/material.dart';

class AppTheme {
  // Modern Dark Red Color Palette
  // Primary: Very deep, dark red - bold and professional
  static const Color primaryColor = Color(0xFF8B0000); // DarkRed - Very dark crimson
  static const Color primaryColorDark = Color(0xFF5A0000); // Even darker
  static const Color primaryColorLight = Color(0xFFD32F2F); // Red 700 - Lighter for dark mode

  // Accent colors - complementary to red
  static const Color accentColor = Color(0xFFFF8A65); // Deep Orange 300 - Soft Coral
  static const Color secondaryColor = Color(0xFFFFCDD2); // Red 100 - Very soft pink/red
  
  // Chart Colors - Distinct from the red theme for visibility
  static const Color chartLineColor1 = Color(0xFF00897B); // Teal - High contrast vs Red
  static const Color chartLineColor2 = Color(0xFFFFA000); // Amber - Warm contrast
  static const Color chartLineColor3 = Color(0xFF3949AB); // Indigo - Cool contrast

  // Warm background tones
  static const Color backgroundColor = Color(0xFFF9F9F9); // Warm Grey
  static const Color surfaceColor = Colors.white;
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFEEEEEE); // Light Grey

  // Semantic colors
  static const Color successColor = Color(0xFF2E7D32); // Dark Green
  static const Color warningColor = Color(0xFFF9A825); // Yellow 800
  static const Color errorColor = Color(0xFFD32F2F); // Red 700 - Consistent with theme but distinct usage

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Color(0xFF212121); // Grey 900
  static const Color onBackground = Color(0xFF424242); // Grey 800
  static const Color textSecondary = Color(0xFF757575); // Grey 600

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // Material 3 Dynamic Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        primaryContainer: secondaryColor,
        onPrimaryContainer: Color(0xFF4A0000), // Very dark red text on pink container
        secondary: accentColor,
        secondaryContainer: Color(0xFFFFE0B2), // Light orange
        tertiary: chartLineColor1, // Teal for tertiary elements
        surface: surfaceColor,
        surfaceContainerHighest: Color(0xFFF5F5F5),
        error: errorColor,
        onPrimary: onPrimary,
        onSecondary: Color(0xFF212121),
        onSurface: onSurface,
        outline: Colors.grey.shade300,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2, // Slight elevation for modern feel
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none, // Clean look, no borders
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onBackground,
          height: 1.5,
        ),
      ),
      iconTheme: const IconThemeData(color: onSurface, size: 24),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColorLight,
      scaffoldBackgroundColor: const Color(0xFF121212), // Darker grey
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorLight,
        brightness: Brightness.dark,
        primary: primaryColorLight,
        primaryContainer: const Color(0xFF5A0000), // Dark red container
        secondary: accentColor,
        secondaryContainer: const Color(0xFF4E342E), // Dark brownish container
        tertiary: chartLineColor1,
        surface: const Color(0xFF1E1E1E),
        error: Color(0xFFCF6679),
        onPrimary: Colors.black, // Dark text on light red primary
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColorLight),
        ),
      ),
    );
  }
}
