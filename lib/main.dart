import 'dart:io';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/chatServices/chatService.dart';
import 'package:hardwaresimu_software_graduation_project/mobileThemeCont.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  CloudinaryObject.fromCloudName(cloudName: 'ds565huxe');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://gosmtymbnsmobgnqzihj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc210eW1ibnNtb2JnbnF6aWhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjM2NzIsImV4cCI6MjA2MjUzOTY3Mn0.XVRWnoX7KwsJbCyO0brSQxeWI229nqB4d8N4xYsMTf4',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SysThemes()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
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
    final ThemeController tc = Provider.of<ThemeController>(context);
    final isLight = tc.isLightTheme(context);

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
                    user: myUser.User(
                      userID: 0,
                      name: '',
                      userName: '',
                      email: '',
                      password: '',
                      phoneNum: '',
                      profileImgUrl: '',
                      isSignedIn: false,
                      isAdmin: false,
                      isVerified: false,
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
