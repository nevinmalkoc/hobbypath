import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🏺 1. Doğal & Sıcak Zanaat Paleti (Warm Terracotta & Sand / Sage Green)
  static const Color primaryColor = Color(0xFFC85A32); // Warm Terracotta / Pişmiş Toprak
  static const Color primaryLight = Color(0xFFF7E6DF); // Soft Terracotta Tint
  static const Color accentColor = Color(0xFF52796F); // Soothing Sage Green / Adaçayı
  static const Color accentLight = Color(0xFFE2EBE8); // Soft Sage Tint
  static const Color warmAmber = Color(0xFFD99B36); // Warm Amber / Bal Kehribar
  static const Color textDark = Color(0xFF2B2421); // Deep Espresso
  static const Color textMuted = Color(0xFF736A65); // Warm Taupe Grey
  static const Color surfaceColor = Color(0xFFFAF7F2); // Warm Linen / Yulaf Kremi
  static const Color cardColor = Colors.white; // Pure Paper White
  static const Color cardBorder = Color(0xFFEFE7DE); // Soft Warm Border

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: warmAmber,
        surface: surfaceColor,
        surfaceContainerLow: cardColor,
        onSurface: textDark,
        onPrimary: Colors.white,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1.2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryLight,
        elevation: 2,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5EFE9),
        disabledColor: const Color(0xFFEFE9E2),
        selectedColor: primaryLight,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: const TextStyle(fontSize: 12, color: textDark, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3ECE4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textMuted,
        indicatorColor: primaryColor,
        dividerColor: cardBorder,
      ),
    );
  }
}
