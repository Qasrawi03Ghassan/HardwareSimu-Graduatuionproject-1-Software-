import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme.dart';
import 'package:hardwaresimu_software_graduation_project/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    runApp(const WebApp());
  } else if (Platform.isAndroid || Platform.isIOS) {
    runApp(const MainApp());
  } else {
    //Do nothing
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: SysThemes().lightTheme,
      darkTheme: SysThemes().darkTheme,
      themeMode: ThemeMode.system,
      home: WelcomePage(),
    );
  }
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Center(
        child: Text("Hello web app!"),
      ),
    );
  }
}
