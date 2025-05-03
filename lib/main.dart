import 'dart:io';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/chatServices/chatService.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';

Future<void> main() async {
  CloudinaryObject.fromCloudName(cloudName: 'ds565huxe');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SysThemes()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: const MainApp(),
    ),
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
                  ? WebApp(
                    isSignedIn: false,
                    user: User(
                      userID: 0,
                      name: '',
                      userName: '',
                      email: '',
                      password: '',
                      phoneNum: '',
                      profileImgUrl: '',
                      isSignedIn: false,
                    ),
                  )
                  : (Platform.isAndroid || Platform.isIOS)
                  ? WelcomePage()
                  : null,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
