import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFCC0000),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFCC0000),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontFamily: 'Pokemon',
      fontSize: 28,
      letterSpacing: 3.0,
      fontWeight: FontWeight.normal,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontSize: 14,
    ),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFCC0000),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white)
);