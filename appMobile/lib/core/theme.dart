import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SakenTheme {
  SakenTheme._();

  static const Color background = Color(0xFFF7F8FA);
  static const Color accent = Color(0xFF1F4E79);
  static const Color paidGreen = Color(0xFF2E7D4F);
  static const Color dueAmber = Color(0xFFB86E00);

  static ThemeData light() {
    final nunito = GoogleFonts.nunito();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: nunito.fontFamily,
      colorScheme: colorScheme.copyWith(primary: accent),
      scaffoldBackgroundColor: background,
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: nunito.fontFamily,
            bodyColor: const Color(0xFF1A1C1E),
            displayColor: const Color(0xFF1A1C1E),
          ).copyWith(
            headlineMedium: TextStyle(
              fontFamily: nunito.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1E),
            ),
            headlineSmall: TextStyle(
              fontFamily: nunito.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1E),
            ),
            titleLarge: TextStyle(
              fontFamily: nunito.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1C1E),
            ),
            bodyLarge: TextStyle(
              fontFamily: nunito.fontFamily,
              fontSize: 16,
              height: 1.4,
              color: const Color(0xFF1A1C1E),
            ),
            bodyMedium: TextStyle(
              fontFamily: nunito.fontFamily,
              fontSize: 16,
              height: 1.4,
              color: const Color(0xFF1A1C1E),
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1C1E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: nunito.fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1C1E),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: TextStyle(
            fontFamily: nunito.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: accent.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: nunito.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
