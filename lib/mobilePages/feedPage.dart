import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/chatPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/notifsPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/profilePage.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My feed",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: const Center(
        child: Text(
          "Community posts appear here",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
    // body: SingleChildScrollView(
    //   padding: const EdgeInsets.all(15),
    //   child: Container(
    //     height: 200,
    //     decoration: BoxDecoration(
    //         border: Border.all(color: Colors.blue.shade600, width: 3),
    //         borderRadius: BorderRadius.circular(12)),
    //   ),
    // ),
    /*return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: TextField(
            controller: postController,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  if (postController.text.isNotEmpty) {
                    _addPost(postController.text);
                    postController.clear();
                  }
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(posts[index]['content'],
                          style: TextStyle(fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up, color: Colors.blue),
                                onPressed: () => _likePost(index),
                              ),
                              Text("${posts[index]['likes']} likes"),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController commentController =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: Text("Add Comment"),
                                    content: TextField(
                                        controller: commentController),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (commentController
                                              .text.isNotEmpty) {
                                            _addComment(
                                                index, commentController.text);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text("Post"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      if (posts[index]['comments'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: posts[index]['comments']
                              .map<Widget>((comment) => Text("- $comment"))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );*/
  }
}
