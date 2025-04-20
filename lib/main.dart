import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(create: (_) => SysThemes(), child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SysThemes>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: "CircuitAcademy",
          theme: themeNotifier.lightTheme,
          darkTheme: themeNotifier.darkTheme,
          themeMode: themeNotifier.tMode,
          home:
              kIsWeb
                  ? WebApp(isSignedIn: false) //Running on web
                  : (Platform.isAndroid || Platform.isIOS)
                  ? WelcomePage() //Running on mobile
                  : null, //Running on desktop which we wont implement
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
