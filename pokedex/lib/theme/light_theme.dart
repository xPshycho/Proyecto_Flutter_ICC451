import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFCC0000),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
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
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    headlineLarge: TextStyle(
      color: Colors.black,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
);