import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/chatBubble.dart';
import 'package:hardwaresimu_software_graduation_project/chatServices/chatService.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/chatPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/mobileChatScreen.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class chatComps extends StatefulWidget {
  final myUser.User? user;
  bool isLightTheme;
  chatComps({super.key, required this.user, required this.isLightTheme});

  @override
  State<chatComps> createState() => _chatCompsState();
}

class _chatCompsState extends State<chatComps> {
  List<myUser.User> _users = [];
  Timer? _refreshTimer;

  myUser.User? selectedUser;
  String selectedUserFsId = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) _fetchUsers(); // fetch updated user list every 5s
    });
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/users'
            : 'http://10.0.2.2:3000/api/users',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _users = json.map((item) => myUser.User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  void onBack() {
    setState(() {
      selectedUser = null;
    });
  }

  Future<String?> getUidByEmail(String targetEmail) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['email'] == targetEmail) {
        selectedUserFsId = doc.id;
        return doc.id; // This is the UID
      }
    }

    return null; // Return null if no match is found
  }

  @override
  Widget build(BuildContext context) {
    //if (kIsWeb) {
    if (selectedUser == null) {
      return chatSection(widget.isLightTheme, widget.user!);
    } else {
      getUidByEmail(selectedUser!.email);
      //print(selectedUserFsId);
      //return Placeholder();
      return ChatPage(
        theme: widget.isLightTheme,
        signedUser: widget.user!,
        selectedUser: selectedUser!,
        receiverId: selectedUserFsId,
        receiverEmail: selectedUser!.email,
        onBack: () {
          setState(() {
            selectedUser = null;
          });
        },
      );
    }
  }

  /*Widget chatPage(
    bool theme,
    myUser.User u,
    myUser.User selectedUser,
    VoidCallback onBack,
  ) {
    final String receivedUserEmail = '';
    final String receivedUserId = '';

    return StatefulBuilder(
      builder: (context, setState) {
        final TextEditingController _messageController =
            TextEditingController();
        final ChatService _chatService = ChatService();
        final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

        void sendMessage() async {
          if (_messageController.text.isNotEmpty) {
            await _chatService.sendMessage(
              receivedUserId,
              _messageController.text,
            );
            _messageController.clear();
          }
        }

        return Container(
          alignment: Alignment.center,
          child: Wrap(
            children: [
              const SizedBox(width: 10),
              InkWell(
                onTap: onBack,
                child: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                selectedUser.name,
                style: GoogleFonts.comfortaa(
                  fontSize: 25,
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }*/

  /*Widget _buildUsersList(bool theme, myUser.User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        final docs = snapshot.data!.docs;

        final List<myUser.User> filteredUsers =
            docs
                .map(
                  (doc) =>
                      myUser.User.fromMap(doc.data() as Map<String, dynamic>),
                )
                .where((u) => u.email != user.email)
                .toList();

        filteredUsers.sort(
          (a, b) => (b.isSignedIn ? 1 : 0).compareTo(a.isSignedIn ? 1 : 0),
        );

        return ListView.separated(
          shrinkWrap: true,
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final myUser.User userX = filteredUsers[index];
            return InkWell(
              onTap: () {
                if (kIsWeb) {
                  // Assuming this is in a stateful widget
                  // and `selectedUser` is declared at the state level
                  (context as Element)
                      .markNeedsBuild(); // or use setState if inside the same widget
                  selectedUser = userX;
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Mobilechatscreen(
                            signedUser: user,
                            selectedUser: userX,
                          ),
                    ),
                  );
                }
              },
              child: buildUser(theme, userX),
            );
          },
          separatorBuilder: (context, index) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 400,
                    child: Divider(
                      thickness: 3,
                      color:
                          theme ? Colors.blue.shade600 : Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }*/

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        }

        return Column(
          //ListView
          children:
              snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItem(doc))
                  .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (FirebaseAuth.instance.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    theme: widget.isLightTheme,
                    signedUser: widget.user!,
                    selectedUser: selectedUser!,
                    receiverId: data['uid'],
                    receiverEmail: data['email'],
                    onBack: onBack,
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget chatSection(bool theme, myUser.User user) {
    final filteredUsers = _users.where((u) => u.userID != user.userID).toList();

    filteredUsers.sort(
      (a, b) => (b.isSignedIn ? 1 : 0).compareTo(a.isSignedIn ? 1 : 0),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Chat with others',
            style: GoogleFonts.comfortaa(
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 40),
          ListView.separated(
            shrinkWrap: true,
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userX = filteredUsers[index];
              return InkWell(
                onTap: () {
                  if (kIsWeb) {
                    setState(() {
                      selectedUser = userX;
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Mobilechatscreen(
                              signedUser: user,
                              selectedUser: userX,
                            ),
                      ),
                    );
                  }
                },
                child: buildUser(theme, userX),
              );
            },
            separatorBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 400,
                      child: Divider(
                        thickness: 3,
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Container buildUser(bool theme, myUser.User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      height: 100,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Tooltip(
              message: user.userName,
              textStyle: GoogleFonts.comfortaa(
                color: theme ? Colors.white : Colors.black,
              ),
              decoration: BoxDecoration(
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
              child:
                  (user.profileImgUrl == null ||
                          user.profileImgUrl!.isEmpty ||
                          user.profileImgUrl == 'defU')
                      ? Image.asset(
                        'Images/defProfile.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        user.profileImgUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            user.userName,
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
          const Spacer(),
          onlineStatus(theme, user),
        ],
      ),
    );
  }

  Widget onlineStatus(bool theme, myUser.User u) {
    if (u.isSignedIn) {
      return Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              'Online',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                color: (theme ? Colors.blue.shade600 : Colors.green.shade600),
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        'Offline',
        style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.grey),
      );
    }
  }
}

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final bool theme;
  final myUser.User signedUser;
  final myUser.User selectedUser;
  final VoidCallback onBack;

  ChatPage({
    super.key,
    required this.theme,
    required this.signedUser,
    required this.selectedUser,
    required this.receiverId,
    required this.receiverEmail,
    required this.onBack,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Wrap(
        children: [
          const SizedBox(width: 10),
          InkWell(
            onTap: widget.onBack,
            child: Icon(
              FontAwesomeIcons.arrowLeft,
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.selectedUser.name,
            style: GoogleFonts.comfortaa(
              fontSize: 25,
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
          //SingleChildScrollView(
          /*child:*/ Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Messages
              Container(height: 750, child: _buildMessageList()),
              //User input
              _buildMessageInput(),
            ],
          ),
          //),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        _firebaseAuth.currentUser!.uid,
        widget.receiverId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }
        return ListView(
          children:
              snapshot.data!.docs
                  .map((document) => _buildMessageItem(document))
                  .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment =
        (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? Alignment.centerRight
            : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment:
            (data['senderId'] == _firebaseAuth.currentUser!.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Text(
            data['senderEmail'],
            style: GoogleFonts.comfortaa(
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 5),
          ChatBubble(theme: widget.theme, message: data['message']),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: TextStyle(
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
            controller: _messageController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.theme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
              label: Text(
                'Enter message',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color:
                      widget.theme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
            ),
            obscureText: false,
          ),
        ),

        IconButton(
          onPressed: sendMessage,
          icon: Icon(
            Icons.send,
            size: 30,
            color: widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
          ),
        ),
      ],
    );
  }
}
