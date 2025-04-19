import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/chatPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/notifsPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/profilePage.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';

class FeedPage extends StatefulWidget {
  final AuthService _authService = AuthService();

  FeedPage({super.key});
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool isLightTheme = false;

  int _selectedIndex = 0;
  List<Map<String, dynamic>> posts = [];

  final List<Widget> _pages = [
    const FeedScreen(),
    //FeedScreen(),
    const ChatScreen(),
    const NotifsScreen(),
    const ProfileScreen(),
  ];

  /*void _addPost(String content) {
    setState(() {
      posts.insert(0, {'content': content, 'likes': 0, 'comments': []});
    });
  }

  void _likePost(int index) {
    setState(() {
      posts[index]['likes']++;
    });
  }

  void _addComment(int index, String comment) {
    setState(() {
      posts[index]['comments'].add(comment);
    });
  }*/

  @override
  Widget build(BuildContext context) {
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
          //BottomNavigationBarItem(icon: Icon(Icons.book), label: "Catalog"),
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
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> posts = [];
  TextEditingController postController = TextEditingController();

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
