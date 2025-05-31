import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireAuth;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/chatServices/chatService.dart';
import 'package:hardwaresimu_software_graduation_project/meetingPagesAndServices/meetingScreen.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobileThemeCont.dart';
import 'package:hardwaresimu_software_graduation_project/notificationsServices/notifsProvider.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:hardwaresimu_software_graduation_project/webPages/webAboutScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webContactScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webHomeScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webSimFromAdel.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webSimScreen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final String serverUrl =
    kIsWeb
        ? 'localhost'
        : '10.0.2.2'; //todo Use 10.0.2.2 for emulator and 192.168.88.5 for real phone (Change in notifsPage for mobile also)

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

final GlobalKey<FeedPageState> feedPageKey = GlobalKey<FeedPageState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool globalIsSignedIn = false;
myUser.User globalSignedUser = myUser.User(
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
);

final GoRouter _router = GoRouter(
  initialLocation: Uri.base.path == '/' ? '/home' : Uri.base.path,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return WebApp(
          isSignedIn: false,
          child: child,
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
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder:
              (context, state) => WebHomeScreen(
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
              ),
        ),
        GoRoute(
          path: '/community',
          builder:
              (context, state) => WebCommScreen(
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
              ),
        ),
        GoRoute(
          path: '/courses',
          builder:
              (context, state) => WebCoursesScreen(
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
              ),
        ),
        GoRoute(
          path: '/simulator',
          builder: (context, state) => WebSimScreen(isSignedIn: false),
        ),
        GoRoute(path: '/about', builder: (context, state) => WebAboutScreen()),
        GoRoute(
          path: '/contact',
          builder: (context, state) => WebContactScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/startMeeting',
      builder: (context, state) => MeetingScreen(),
    ),
  ],
);

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/notification_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // Add iOS/macOS if needed
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tapped logic here if needed
      if (response.payload == 'chat') {
        feedPageKey.currentState?.goToNotificationsScreen();
      }
    },
  );
}

Future<void> main() async {
  CloudinaryObject.fromCloudName(cloudName: 'ds565huxe');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://gosmtymbnsmobgnqzihj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc210eW1ibnNtb2JnbnF6aWhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjM2NzIsImV4cCI6MjA2MjUzOTY3Mn0.XVRWnoX7KwsJbCyO0brSQxeWI229nqB4d8N4xYsMTf4',
  );

  if (!kIsWeb) {
    initNotifications();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SysThemes()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => MobileThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web: Use SysThemes, minimal rebuilds via Selector
      return Selector<SysThemes, ThemeMode>(
        selector: (_, provider) => provider.tMode,
        builder: (context, themeMode, _) {
          final sysTheme = Provider.of<SysThemes>(context, listen: false);

          return MaterialApp /*.router*/ (
            //didnt have router
            /*routerConfig:
                _router,*/
            initialRoute: Uri.base.path == '/' ? '/' : Uri.base.path,
            title: "CircuitAcademy",
            theme: sysTheme.lightTheme,
            darkTheme: sysTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,

            //todo if breaks uncomment route changes
            onGenerateRoute: (settings) {
              print('Route requested: ${settings.name}');
              final uri = Uri.parse(settings.name ?? '');

              if (uri.path == '/startMeeting') {
                return MaterialPageRoute(builder: (context) => MeetingScreen());
              }
              if (uri.path == '/simulator') {
                return MaterialPageRoute(
                  builder:
                      (context) => Sim(
                        isSignedIn: globalIsSignedIn,
                        user:
                            !globalIsSignedIn && globalSignedUser.userID != 0
                                ? myUser.User(
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
                                )
                                : globalSignedUser,
                      ),
                );
              }

              return MaterialPageRoute(
                builder:
                    (context) => WebApp(
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
                    ),
              );
            },
          );
        },
      );
    }

    // Mobile (Android / iOS)
    if (Platform.isAndroid || Platform.isIOS) {
      return Selector<MobileThemeProvider, ThemeMode>(
        selector: (_, provider) => provider.themeMode,
        builder: (context, themeMode, _) {
          final mobileTheme = Provider.of<MobileThemeProvider>(
            context,
            listen: false,
          );

          return MaterialApp(
            navigatorKey: navKey,
            title: "CircuitAcademy",
            theme: mobileTheme.lightTheme,
            darkTheme: mobileTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthWrapper(), // Use WelcomePage() if needed
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) {
              print('Mobile Route requested: ${settings.name}');
              if (settings.name == '/startMeetingMobile') {
                final args = settings.arguments as Map<String, dynamic>;

                return MaterialPageRoute(
                  builder:
                      (_) => MeetingScreen(
                        meetingIdM: args['meetingId'] ?? '',
                        tokenM: args['token'] ?? '',
                        participantNameM: args['participantName'] ?? '',
                        isHostM: args['isHost'],
                      ),
                );
              }
              return MaterialPageRoute(builder: (_) => const AuthWrapper());
            },
          );
        },
      );
    }

    // Fallback for unsupported platforms
    return const SizedBox.shrink();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fireAuth.User?>(
      stream: fireAuth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return WelcomePage();
        }

        final firebaseUser = snapshot.data!;
        final email = firebaseUser.email;

        if (email == null) {
          showSnackBar('User not found', context);
          return WelcomePage();
        }

        return FutureBuilder<myUser.User?>(
          future: fetchCustomUserFromMongo(email),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (userSnapshot.hasError || !userSnapshot.hasData) {
              showSnackBar('User not found', context);
              return WelcomePage(); // Handle error gracefully
            } else {
              return FeedPage(
                key: feedPageKey,
                user: userSnapshot.data!,
                selectedIndex: 0,
              );
            }
          },
        );
      },
    );
  }

  void showSnackBar(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        backgroundColor: Colors.blue.shade600,
        content: Center(
          child: Text(
            text,
            style: GoogleFonts.comfortaa(
              fontSize: kIsWeb ? 30 : 20,
              color: Colors.white,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Fetch your custom user from MongoDB based on email
  Future<myUser.User?> fetchCustomUserFromMongo(String email) async {
    final response = await http.get(
      Uri.parse('http://${serverUrl}:3000/api/users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final users = json.map((item) => myUser.User.fromJson(item)).toList();

      // Find user by email
      try {
        return users.firstWhere((user) => user.email == email);
      } catch (e) {
        return null;
      }
    } else {
      throw Exception('Failed to load users from MongoDB');
    }
  }
}
