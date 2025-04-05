import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CircuitAcademy",
      theme: SysThemes().lightTheme,
      darkTheme: SysThemes().darkTheme,
      themeMode:
          ThemeMode
              .light, //Change this back to system to have dynamic theme based on device settings
      home:
          kIsWeb
              ? const WebApp() //Running on web
              : (Platform.isAndroid || Platform.isIOS)
              ? WelcomePage() //Running on mobile
              : null, //Running on desktop which we wont implement
    );
  }
}
