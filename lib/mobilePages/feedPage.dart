import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/chatPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/notifsPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/profilePage.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/notificationsServices/firebaseNots.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final myUser.User? user;
  //final AuthService _authService = AuthService();
  final int selectedIndex;

  FeedPage({super.key, required this.user, required this.selectedIndex});
  @override
  FeedPageState createState() => FeedPageState(user: this.user);
}

class FeedPageState extends State<FeedPage> {
  myUser.User? user;
  RemoteMessage? message;

  bool hasUnreadNotifications = false;

  int notifID = 0;

  late int _selectedIndex;
  FeedPageState({required this.user});

  bool get isOnChatScreen => _selectedIndex == 2;

  GlobalKey<NavigatorState> notificationsNavigatorKey =
      GlobalKey<NavigatorState>();

  void goToNotificationsScreen() {
    setState(() {
      _selectedIndex = 3; // Set to the index of Notifications tab
      hasUnreadNotifications = false;
    });

    // Optionally pop to root if nested navigation
    notificationsNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void showNotification(RemoteMessage newMessage) {
    setState(() {
      message = newMessage;
      //hasUnreadNotifications = true;
      _selectedIndex = 3; // Switch to Notifications tab
    });
  }

  void showNotificationOnApp(RemoteMessage newMessage) {
    setState(() {
      //message = newMessage;
      hasUnreadNotifications = true;
    });
  }

  void showChatNotif({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chat_channel', // channel id
          'Chat Notifications', // channel name
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notifID++, // notification id (unique for each notif or 0 for overwrite)
      title,
      body,
      platformChannelSpecifics,
      payload: 'chat', // optional payload
    );
  }

  void clearUnreadNotifications() {
    setState(() {
      hasUnreadNotifications = false;
    });
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _selectedIndex = widget.selectedIndex;
    initNotifs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is RemoteMessage) {
        setState(() {
          message = args;
          if (_selectedIndex != 3) {
            _selectedIndex = 3; // go to notifications only if not already there
          }
        });
      }
    });
  }

  void initNotifs() async {
    await FirebaseNots().initNotification(user);
  }

  bool isLightTheme = false;

  //int _selectedIndex = 0;
  List<Map<String, dynamic>> posts = [];

  void handleNotificationMessage(RemoteMessage message) {
    setState(() {
      _selectedIndex = 3; // switch to notifications tab
      // Save the message so the notifications page can display it
      this.message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FeedScreen(user: user),
      //WebCommScreen(isSignedIn: true, user: user),
      WebCoursesScreen(isSignedIn: true, user: user),
      ChatScreen(user: user),
      NotifsScreen(user: user, message: message),
      ProfileScreen(user: user),
    ];

    isLightTheme = Provider.of<MobileThemeProvider>(
      context,
    ).isLightTheme(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CircuitAcademy"),
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor:
            isLightTheme ? Colors.blue.shade600 : Colors.green.shade600,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 3) {
              clearUnreadNotifications();
            }
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon:
                (user!.profileImgUrl != null)
                    ? Container(
                      height: 45,
                      width: 45,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color:
                            isLightTheme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            (user!.profileImgUrl != null &&
                                    user!.profileImgUrl != '')
                                ? CachedNetworkImage(
                                  //image.network
                                  imageUrl: user!.profileImgUrl!,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'Images/defProfile.jpg',
                                  fit: BoxFit.cover,
                                ),
                      ),
                    )
                    : Icon(Icons.person),
            label: "My Profile",
          ),
        ],
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  final myUser.User? user;
  const FeedScreen({super.key, required this.user});

  @override
  _FeedScreenState createState() => _FeedScreenState(user: this.user);
}

class _FeedScreenState extends State<FeedScreen> {
  myUser.User? user;
  _FeedScreenState({required this.user});

  List<Map<String, dynamic>> posts = [];
  TextEditingController postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebCommScreen(isSignedIn: true, user: widget.user));
  }
}
