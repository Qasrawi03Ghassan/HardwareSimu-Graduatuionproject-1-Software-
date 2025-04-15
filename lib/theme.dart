import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SysThemes with ChangeNotifier {
  ThemeMode tMode = ThemeMode.system;

  ThemeMode get themeMode => tMode;

  bool isLightTheme = true;

  void toggleTheme() {
    isLightTheme = !isLightTheme;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    tMode = mode;
    notifyListeners();
  }

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue.shade600,
    colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
    appBarTheme: AppBarTheme(
      color: Colors.blue.shade600,
      titleTextStyle: GoogleFonts.comfortaa(
        color: Colors.white,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.green.shade600,
    colorScheme: const ColorScheme.dark(primary: Colors.greenAccent),
    appBarTheme: AppBarTheme(
      color: Colors.black,
      titleTextStyle: GoogleFonts.comfortaa(
        color: Colors.green.shade600,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
