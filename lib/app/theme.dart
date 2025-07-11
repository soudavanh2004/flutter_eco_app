import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF65A986);
  static const Color backgroundColor = Color(0xFFF2FFF5);
  static const Color textColor = Color(0xFF333333);

  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'NotoSansLao', // ✅ <<<<<<<<<<<< เพิ่มบรรทัดนี้
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
