import 'package:flutter/material.dart';

const Color kLightBackgroundColor = Color(0xFFFFFFFF);
const Color kLightPrimaryColor = Color(0xFFCC0000);
const Color kLightSurfaceColor = Color(0xFFFFFFFF);
const Color kLightOnPrimaryColor = Colors.white;
const Color kLightOnSurfaceColor = Colors.black;

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