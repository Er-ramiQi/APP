// lib/config/themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  // Couleurs primaires pour le thème clair
  static const Color _lightPrimaryColor = Color(0xFF2196F3); // Bleu
  static const Color _lightPrimaryVariantColor = Color(0xFF1976D2); // Bleu foncé
  static const Color _lightSecondaryColor = Color(0xFF4CAF50); // Vert
  
  // Couleurs primaires pour le thème sombre
  static const Color _darkPrimaryColor = Color(0xFF90CAF9); // Bleu clair
  static const Color _darkPrimaryVariantColor = Color(0xFF64B5F6); // Bleu moyen
  static const Color _darkSecondaryColor = Color(0xFF81C784); // Vert clair
  
  // Couleurs d'erreur
  static const Color _errorColor = Color(0xFFE53935); // Rouge
  
  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryContainer: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      error: _errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Thème de carte
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    // Thème de bouton élevé
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Thème de bouton plat
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),
    // Thème de bouton avec contour
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        side: const BorderSide(color: _lightPrimaryColor),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Thème de bouton flottant
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    // Thème d'entrée de texte
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
    // Thème de switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400;
          }
          if (states.contains(WidgetState.selected)) {
            return _lightPrimaryColor;
          }
          return Colors.grey.shade50;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade200;
          }
          if (states.contains(WidgetState.selected)) {
            return _lightPrimaryColor.withValues(alpha: 128);
          }
          return Colors.grey.shade300;
        },
      ),
    ),
    // Thème de dialogue
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
    ),
    // Thème de snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  
  // Thème sombre
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      primaryContainer: _darkPrimaryVariantColor,
      secondary: _darkSecondaryColor,
      error: _errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Thème de carte
    cardTheme: CardTheme(
      color: const Color(0xFF2E2E2E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    // Thème de bouton élevé
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: _darkPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Thème de bouton plat
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),
    // Thème de bouton avec contour
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        side: const BorderSide(color: _darkPrimaryColor),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // Thème de bouton flottant
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.black,
    ),
    // Thème d'entrée de texte
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: const Color(0xFF3E3E3E),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
    // Thème de switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade700;
          }
          if (states.contains(WidgetState.selected)) {
            return _darkPrimaryColor;
          }
          return Colors.grey.shade300;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade800;
          }
          if (states.contains(WidgetState.selected)) {
            return _darkPrimaryColor.withOpacity(0.5);
          }
          return Colors.grey.shade700;
        },
      ),
    ),
    // Thème de dialogue
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF2E2E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
    ),
    // Thème de snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}