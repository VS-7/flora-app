import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores primárias
  static const Color primaryGreen = Color(0xFF1DAB61);
  static const Color primaryDarkGreen = Color(0xFF15603E);
  static const Color accentGreen = Color(0xFFD0FECF);

  // Cores secundárias
  static const Color earthBrown = Color(0xFF795548);
  static const Color warmBeige = Color(0xFFFFFFFF);
  static const Color skyBlue = Color(0xFF03A9F4);

  // Cores de feedback
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color infoBlue = Color(0xFF29B6F6);

  // Cores de fundo
  static const Color darkBackground = Color.fromARGB(255, 15, 15, 15);
  static const Color darkSurface = Color.fromARGB(255, 15, 15, 15);
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;

  // Modo claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: accentGreen,
        onSecondary: Colors.white,
        tertiary: earthBrown,
        background: lightBackground,
        surface: lightSurface,
        error: errorRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        elevation: 0,
        color: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        titleLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryDarkGreen,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryDarkGreen,
        ),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, color: Colors.black87),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, color: Colors.black87),
        labelMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      iconTheme: const IconThemeData(color: primaryDarkGreen),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Modo escuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: accentGreen,
        onSecondary: Colors.white,
        tertiary: earthBrown,
        background: darkBackground,
        surface: darkSurface,
        error: errorRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        elevation: 0,
        color: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2C2C2C),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        titleLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
        labelMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      iconTheme: const IconThemeData(color: accentGreen),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
