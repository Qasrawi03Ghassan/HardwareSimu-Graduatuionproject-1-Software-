import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeController with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  void setTheme(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  bool isLightTheme(BuildContext context) {
    if (_themeMode == AppThemeMode.light) return true;
    if (_themeMode == AppThemeMode.dark) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.light;
  }
}
