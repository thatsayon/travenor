import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14),
        bodyLarge: TextStyle(fontSize: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
