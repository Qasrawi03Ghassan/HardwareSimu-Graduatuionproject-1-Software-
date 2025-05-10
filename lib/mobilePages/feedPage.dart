import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/chatPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/notifsPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/profilePage.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:hardwaresimu_software_graduation_project/webPages/webCommScreen.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webCoursesScreen.dart';

class FeedPage extends StatefulWidget {
  final myUser.User? user;
  final AuthService _authService = AuthService();

  FeedPage({super.key, required this.user});
  @override
  _FeedPageState createState() => _FeedPageState(user: this.user);
}

class _FeedPageState extends State<FeedPage> {
  myUser.User? user;
  _FeedPageState({required this.user});

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  bool isLightTheme = false;

  int _selectedIndex = 0;
  List<Map<String, dynamic>> posts = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FeedScreen(user: user),
      //WebCommScreen(isSignedIn: true, user: user),
      WebCoursesScreen(isSignedIn: true, user: user),
      ChatScreen(user: user),
      NotifsScreen(user: user),
      ProfileScreen(user: user),
    ];
    isLightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
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
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
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
                                ? Image.network(
                                  user!.profileImgUrl!,
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
