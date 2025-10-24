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
  scaffoldBackgroundColor: Color(0xFF121212),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
    ),
    headlineLarge: TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
);