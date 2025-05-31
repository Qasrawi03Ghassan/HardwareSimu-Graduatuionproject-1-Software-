import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { light, dark, system }

class MobileThemeProvider with ChangeNotifier {
  AppThemeMode _selectedMode = AppThemeMode.system;

  AppThemeMode get selectedMode => _selectedMode;

  // This bool tells if the effective theme is light or not,
  // it depends on the user choice and system brightness if system mode
  bool isLightTheme(BuildContext context) {
    if (_selectedMode == AppThemeMode.light) return true;
    if (_selectedMode == AppThemeMode.dark) return false;
    // system: check platform brightness
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.light;
  }

  void setTheme(AppThemeMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_selectedMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  // Your mobile light and dark ThemeData, customize as needed
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
