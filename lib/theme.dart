import 'package:flutter/material.dart';

// Light theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1976D2), // Azul vibrante
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1976D2),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF1976D2),
      side: BorderSide(color: Color(0xFF1976D2)),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: Color(0xFF1976D2)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
    bodyMedium: TextStyle(color: Color(0xFF333333)),
  ),
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1976D2),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF22223B),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF90CAF9),
      side: BorderSide(color: Color(0xFF90CAF9)),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Color(0xFF22223B),
    labelStyle: TextStyle(color: Color(0xFF90CAF9)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF90CAF9), width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF22223B),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF90CAF9)),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);
