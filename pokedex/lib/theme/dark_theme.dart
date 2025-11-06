import 'package:flutter/material.dart';

// Theme constants: change these values to modify the look of the dark theme.
// Colors are defined here for easy manual modification.
const Color kDarkBackgroundColor = Color(0xFF121212); // Entire app background (single color)
const Color kDarkPrimaryColor = Color(0xFFCC0000); // Primary color (buttons, app bar)
const Color kDarkSurfaceColor = Color(0xFF1E1E1E); // Surface (cards, inputs)
const Color kDarkOnPrimaryColor = Colors.white; // Text/icons on primary
const Color kDarkOnSurfaceColor = Colors.white; // Text/icons on surface

// Font: the main font family used across the app. Ensure the font is declared in pubspec.yaml.
// To change the main font, replace 'Pixelated' with your font family name.
const String kMainFontFamily = 'Pixelated';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  // Use the color constants above to make manual edits easy.
  colorScheme: const ColorScheme.dark(
    primary: kDarkPrimaryColor,
    surface: kDarkSurfaceColor,
    onPrimary: kDarkOnPrimaryColor,
    onSecondary: kDarkOnPrimaryColor,
    onSurface: kDarkOnSurfaceColor,
  ),
  // Entire background will be a single color. Change kDarkBackgroundColor to update it.
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