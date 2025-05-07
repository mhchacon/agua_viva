import 'package:flutter/material.dart';

// Light theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5), // Blue
    brightness: Brightness.light,
  ),
  // Add other theme configurations here
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5), // Blue
    brightness: Brightness.dark,
  ),
  // Add other theme configurations here
);
