import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5),
    brightness: Brightness.light,
  ),
  // Material 2 mantenido intencionalmente para consistencia visual de la app.
  // Migrar a Material 3 requiere revisar todos los componentes de UI.
  useMaterial3: false,
  textTheme: GoogleFonts.poppinsTextTheme(),
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardThemeData(
    margin: const EdgeInsets.all(12),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[50],
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      color: const Color(0xFF1E88E5),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
  ),
);