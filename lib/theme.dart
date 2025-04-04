import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SysThemes {
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
    appBarTheme: AppBarTheme(
        color: Colors.blue.shade600,
        titleTextStyle: GoogleFonts.comfortaa(
            color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
    appBarTheme: AppBarTheme(
        color: Colors.black,
        titleTextStyle: GoogleFonts.comfortaa(
            color: Colors.green, fontSize: 35, fontWeight: FontWeight.bold)),
  );
}
