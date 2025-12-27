import 'package:flutter/material.dart';

const Color kDarkBackgroundColor = Color(0xFF121212);
const Color kDarkPrimaryColor = Color(0xFFCC0000);
const Color kDarkSurfaceColor = Color(0xFF1E1E1E);
const Color kDarkOnPrimaryColor = Colors.white;
const Color kDarkOnSurfaceColor = Colors.white;

const String kMainFontFamily = 'Pixelated';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: kDarkPrimaryColor,
    surface: kDarkSurfaceColor,
    onPrimary: kDarkOnPrimaryColor,
    onSecondary: kDarkOnPrimaryColor,
    onSurface: kDarkOnSurfaceColor,
  ),
  scaffoldBackgroundColor: kDarkBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkPrimaryColor,
    foregroundColor: kDarkOnPrimaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: kDarkOnPrimaryColor,
      fontFamily: kMainFontFamily,
      fontSize: 28,
      letterSpacing: 3.0,
      fontWeight: FontWeight.normal,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: kDarkOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: kDarkOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontSize: 14,
    ),
    headlineLarge: TextStyle(
      color: kDarkOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkPrimaryColor,
      foregroundColor: kDarkOnPrimaryColor,
      textStyle: const TextStyle(fontFamily: kMainFontFamily, fontSize: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  iconTheme: const IconThemeData(color: kDarkOnSurfaceColor),
);