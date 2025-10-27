import 'package:flutter/material.dart';

// Theme constants: modify these to change the light theme appearance.
const Color kLightBackgroundColor = Color(0xFFFFFFFF); // Entire app background (single color)
const Color kLightPrimaryColor = Color(0xFFCC0000); // Primary color (buttons, app bar)
const Color kLightSurfaceColor = Color(0xFFFFFFFF); // Surface (cards, inputs)
const Color kLightOnPrimaryColor = Colors.white; // Text/icons on primary
const Color kLightOnSurfaceColor = Colors.black; // Text/icons on surface

// Font: change this to your preferred font family (ensure it's declared in pubspec.yaml)
const String kMainFontFamily = 'Pixelated';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: kLightPrimaryColor,
    surface: kLightSurfaceColor,
    onPrimary: kLightOnPrimaryColor,
    onSecondary: kLightOnPrimaryColor,
    onSurface: kLightOnSurfaceColor,
  ),
  // Entire background will be one solid color. Change kLightBackgroundColor to update it.
  scaffoldBackgroundColor: kLightBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightPrimaryColor,
    foregroundColor: kLightOnPrimaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: kLightOnPrimaryColor,
      fontFamily: kMainFontFamily,
      fontSize: 28,
      letterSpacing: 3.0,
      fontWeight: FontWeight.normal,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: kLightOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: kLightOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontSize: 14,
    ),
    headlineLarge: TextStyle(
      color: kLightOnSurfaceColor,
      fontFamily: kMainFontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kLightPrimaryColor,
      foregroundColor: kLightOnPrimaryColor,
      textStyle: const TextStyle(fontFamily: kMainFontFamily, fontSize: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black)
);