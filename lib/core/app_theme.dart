import 'package:flutter/material.dart';

class AppTheme {
  // Warm, Supportive & Reassuring Color Palette for Parents & Caregivers
  // Soft pastel blues - calming and trustworthy
  static const Color primaryColor = Color(0xFF5B9BD5); // Soft sky blue - warm and approachable
  static const Color primaryColorDark = Color(0xFF4A7BA7); // Deeper but still soft blue
  static const Color primaryColorLight = Color(0xFF8BB8E8); // Light pastel blue
  
  // Pastel accent colors - gentle and supportive
  static const Color accentColor = Color(0xFFB8D4F0); // Very light pastel blue
  static const Color secondaryColor = Color(0xFFE8F4F8); // Soft mint-blue
  
  // Warm background tones - reduces stress
  static const Color backgroundColor = Color(0xFFFAFBFC); // Warm off-white
  static const Color surfaceColor = Colors.white;
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE8ECF0); // Very soft gray divider
  
  // Gentle accent colors - non-aggressive
  static const Color successColor = Color(0xFF7BC8A4); // Soft pastel green
  static const Color warningColor = Color(0xFFFFD89B); // Warm pastel amber
  static const Color errorColor = Color(0xFFFF9B9B); // Soft pastel red - not alarming
  
  // Text colors - warm and readable
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Color(0xFF2C3E50); // Warm dark blue-gray
  static const Color onBackground = Color(0xFF4A5568); // Medium warm gray
  static const Color textSecondary = Color(0xFF718096); // Soft warm gray for secondary text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // Material 3 Dynamic Color Scheme - warm and supportive
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        primaryContainer: accentColor, // Very light pastel blue
        secondary: secondaryColor, // Soft mint-blue
        secondaryContainer: Color(0xFFF0F7FA), // Even lighter pastel
        tertiary: Color(0xFFF5F8FA), // Warm soft gray
        surface: surfaceColor,
        surfaceContainerHighest: Color(0xFFF8FAFB), // Subtle surface variation
        error: errorColor,
        errorContainer: Color(0xFFFFE5E5), // Soft error background
        onPrimary: onPrimary,
        onSecondary: onSurface,
        onSurface: onSurface,
        onError: Colors.white,
        outline: dividerColor, // Gentle borders
        outlineVariant: Color(0xFFE8ECF0), // Even gentler borders
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0, // Flat Material 3 style
        surfaceTintColor: Colors.transparent, // Material 3 - no tint
        centerTitle: false, // Left align for better readability
        iconTheme: const IconThemeData(
          color: onPrimary,
          size: 24, // Friendly, approachable size
        ),
        titleTextStyle: const TextStyle(
          color: onPrimary,
          fontSize: 22, // Larger for accessibility
          fontWeight: FontWeight.w500, // Softer weight - less aggressive
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0, // Material 3 - flat with surface tint
        shadowColor: Colors.transparent, // No harsh shadows
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded - friendly
          side: BorderSide(
            color: dividerColor.withValues(alpha: 0.5), // Very gentle border
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Generous spacing
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 0, // Material 3 - flat
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18), // Generous padding
          minimumSize: const Size(120, 52), // Larger touch target - easier for stressed parents
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Very rounded - friendly
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Softer weight
            letterSpacing: 0.3,
          ),
        ),
      ),
      // Outlined button theme for secondary actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(120, 52),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(80, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 2, // Gentle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded FAB
        ),
      ),
      // Icon theme - friendly and approachable
      iconTheme: IconThemeData(
        color: onSurface.withValues(alpha: 0.7), // Soft icons
        size: 24,
      ),
      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: onPrimary,
        size: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFAFBFC), // Very light warm background
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Generous padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // More rounded
          borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorColor.withValues(alpha: 0.6), width: 1.5), // Softer error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorColor.withValues(alpha: 0.8), width: 2),
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          color: textSecondary,
          fontWeight: FontWeight.w400, // Lighter weight
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: textSecondary.withValues(alpha: 0.7), // Softer hint
        ),
      ),
      textTheme: TextTheme(
        // Large display text - warm and welcoming
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400, // Lighter - less aggressive
          color: onSurface,
          letterSpacing: -0.2,
          height: 1.3, // More breathing room
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: onSurface,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: onSurface,
          letterSpacing: 0,
          height: 1.4,
        ),
        // Headlines - gentle and clear
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500, // Softer weight
          color: onSurface,
          letterSpacing: 0,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: 0,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: 0,
          height: 1.5,
        ),
        // Titles - friendly and readable
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500, // Softer
          color: onSurface,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        // Body text - generous spacing for stressed parents
        bodyLarge: TextStyle(
          fontSize: 17, // Larger for accessibility
          fontWeight: FontWeight.w400, // Normal weight - easy to read
          color: onSurface,
          letterSpacing: 0.1,
          height: 1.6, // More line height - reduces eye strain
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: onSurface,
          letterSpacing: 0.1,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        // Label text - for form labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textSecondary.withValues(alpha: 0.8),
          letterSpacing: 0.1,
          height: 1.3,
        ),
      ),
      // Divider theme - very subtle
      dividerTheme: DividerThemeData(
        color: dividerColor.withValues(alpha: 0.3), // Very gentle dividers
        thickness: 1,
        space: 1,
      ),
      // List tile theme - friendly spacing
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: onSurface.withValues(alpha: 0.7),
        textColor: onSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Warm dark theme - still supportive but darker
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColorLight,
      scaffoldBackgroundColor: const Color(0xFF1A1F2E), // Warm dark blue-gray
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorLight,
        brightness: Brightness.dark,
        primary: primaryColorLight,
        primaryContainer: Color(0xFF2D3A4F), // Soft dark container
        secondary: Color(0xFF3A4A5F),
        secondaryContainer: Color(0xFF2A3441),
        tertiary: Color(0xFF252B38),
        surface: const Color(0xFF1F2532),
        surfaceContainerHighest: const Color(0xFF252B38),
        error: errorColor,
        errorContainer: Color(0xFF4A2A2A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFE8ECF0), // Soft light text
        onError: Colors.white,
        outline: const Color(0xFF3A4550),
        outlineVariant: const Color(0xFF2A3441),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2532),
        foregroundColor: Color(0xFFE8ECF0),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFE8ECF0), size: 24),
        titleTextStyle: TextStyle(
          color: Color(0xFFE8ECF0),
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2532),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF3A4550).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(120, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252B38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF3A4550).withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF3A4550).withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColorLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorColor.withValues(alpha: 0.6), width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFFA0AEC0),
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: const Color(0xFFA0AEC0).withValues(alpha: 0.7),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE8ECF0),
          letterSpacing: -0.2,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE8ECF0),
          letterSpacing: 0,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE8ECF0),
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE8ECF0),
          letterSpacing: 0.1,
          height: 1.6,
        ),
      ),
    );
  }
}
