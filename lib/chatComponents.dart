/*import 'dart:async';

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
  String? selectedUserFsId = '';

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
      //todo: This is commented because it breaks the whole chat list and it doesn't show if not commented, dont remove the comment even if it gives an exception
      //if (!mounted) {
      setState(() {
        _users = json.map((item) => myUser.User.fromJson(item)).toList();
      });
      //}
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
    if (selectedUser == null) {
      return chatSection(widget.isLightTheme, widget.user!);
    }

    // UID not yet fetched? Show loading spinner
    if (selectedUserFsId == null || selectedUserFsId!.isEmpty) {
      // Trigger UID fetch asynchronously (not inside build directly)
      _resolveReceiverId(selectedUser!.email);
      return Center(
        child: CircularProgressIndicator(
          color:
              widget.isLightTheme
                  ? Colors.blue.shade600
                  : Colors.green.shade600,
        ),
      );
    }

    // UID is ready: show the actual ChatPage
    return ChatPage(
      key: ValueKey(selectedUserFsId), // Forces rebuild on user switch
      theme: widget.isLightTheme,
      signedUser: widget.user!,
      selectedUser: selectedUser!,
      receiverId: selectedUserFsId!,
      receiverEmail: selectedUser!.email,
      onBack: () {
        setState(() {
          selectedUser = null;
          selectedUserFsId = null;
        });
      },
    );
  }

  // Async helper outside build to get the UID
  void _resolveReceiverId(String email) async {
    final uid = await getUidByEmail(
      email,
    ); // make sure this returns Future<String>
    if (mounted) {
      setState(() {
        selectedUserFsId = uid;
      });
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   //if (kIsWeb) {
  //   if (selectedUser == null) {
  //     return chatSection(widget.isLightTheme, widget.user!);
  //   } else {
  //     getUidByEmail(selectedUser!.email);
  //     //print(selectedUserFsId);
  //     //return Placeholder();
  //     return ChatPage(
  //       theme: widget.isLightTheme,
  //       signedUser: widget.user!,
  //       selectedUser: selectedUser!,
  //       receiverId: selectedUserFsId,
  //       receiverEmail: selectedUser!.email,
  //       onBack: () {
  //         setState(() {
  //           selectedUser = null;
  //         });
  //       },
  //     );
  //   }
  // }

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
          return Center(
            child: CircularProgressIndicator(
              color:
                  widget.isLightTheme
                      ? Colors.blue.shade600
                      : Colors.green.shade600,
            ),
          );
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
          return Center(
            child: CircularProgressIndicator(
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No messages to show',
              style: GoogleFonts.comfortaa(
                fontSize: 25,
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
          );
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

    final isMe = data['senderId'] == _firebaseAuth.currentUser!.uid;

    myUser.User senderUser =
        (data['senderEmail'] == widget.signedUser.email)
            ? widget.signedUser
            : widget.selectedUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // If not me, show avatar on the left
          if (!isMe) _buildProfileImage(senderUser.profileImgUrl!),

          // Message bubble and name
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                senderUser.userName,
                style: GoogleFonts.comfortaa(
                  fontSize: 13,
                  color:
                      widget.theme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 5),
              ChatBubble(theme: widget.theme, message: data['message']),
            ],
          ),

          // If me, show avatar on the right
          if (isMe) _buildProfileImage(senderUser.profileImgUrl!),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 16,
        backgroundImage:
            (imageUrl != '')
                ? NetworkImage(imageUrl)
                : AssetImage('Images/defProfile.jpg'),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  // Widget _buildMessageItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  //   var alignment =
  //       (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //           ? Alignment.centerRight
  //           : Alignment.centerLeft;

  //   return Container(
  //     alignment: alignment,
  //     padding: EdgeInsets.symmetric(horizontal: 10),
  //     child: Column(
  //       crossAxisAlignment:
  //           (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //               ? CrossAxisAlignment.end
  //               : CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           data['senderEmail'],
  //           style: GoogleFonts.comfortaa(
  //             color:
  //                 widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
  //           ),
  //         ),
  //         const SizedBox(height: 5),
  //         ChatBubble(theme: widget.theme, message: data['message']),
  //         const SizedBox(height: 10),
  //       ],
  //     ),
  //   );
  // }

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
*/

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
  String? selectedUserFsId;

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
      //todo: This is commented because it breaks the whole chat list and it doesn't show if not commented, dont remove the comment even if it gives an exception
      if (mounted) {
        setState(() {
          _users = json.map((item) => myUser.User.fromJson(item)).toList();
        });
      }
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
        return doc.id;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedUser == null) {
      return chatSection(widget.isLightTheme, widget.user!);
    }

    if (selectedUserFsId == null || selectedUserFsId!.isEmpty) {
      _resolveReceiverId(selectedUser!.email);
      return Center(
        child: CircularProgressIndicator(
          color:
              widget.isLightTheme
                  ? Colors.blue.shade600
                  : Colors.green.shade600,
        ),
      );
    }

    return ChatPage(
      key: ValueKey(selectedUserFsId),
      theme: widget.isLightTheme,
      signedUser: widget.user!,
      selectedUser: selectedUser!,
      receiverId: selectedUserFsId!,
      receiverEmail: selectedUser!.email,
      onBack: () {
        setState(() {
          selectedUser = null;
          selectedUserFsId = null;
        });
      },
    );
  }

  void _resolveReceiverId(String email) async {
    final uid = await getUidByEmail(email);
    if (mounted) {
      setState(() {
        selectedUserFsId = uid;
      });
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
          kIsWeb ? const SizedBox(height: 40) : SizedBox(),
          kIsWeb
              ? Text(
                'Chat with others',
                style: GoogleFonts.comfortaa(
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              )
              : SizedBox(),
          kIsWeb ? const SizedBox(height: 40) : SizedBox(),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // disable inner scrolling
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userX = filteredUsers[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedUser = userX;
                  });
                },
                child: buildUser(theme, userX),
              );
            },
            separatorBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 500 : 250,
                      child: Divider(
                        thickness: 2,
                        color:
                            theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Container buildUser(bool theme, myUser.User user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kIsWeb ? 20 : 10),
      padding: kIsWeb ? const EdgeInsets.all(12) : null,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      height: kIsWeb ? 100 : 80,
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
                        width: kIsWeb ? 80 : 60,
                        height: kIsWeb ? 80 : 60,
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        user.profileImgUrl!,
                        width: kIsWeb ? 80 : 60,
                        height: kIsWeb ? 80 : 60,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          const SizedBox(width: kIsWeb ? 20 : 15),
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
                color: theme ? Colors.blue.shade600 : Colors.green.shade600,
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

  Stream<QuerySnapshot>? _messageStream;
  bool _isLoadingMessages = true;

  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _loadMessagesForUser();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    setState(() {
      _isNearBottom = (maxScroll - currentScroll <= 50);
    });
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receiverId != widget.receiverId) {
      _loadMessagesForUser();
    }
  }

  void _loadMessagesForUser() async {
    setState(() {
      _isLoadingMessages = true;
      _messageStream = const Stream.empty();
    });

    await Future.delayed(const Duration(milliseconds: 150));

    final newStream = _chatService.getMessages(
      _firebaseAuth.currentUser!.uid,
      widget.receiverId,
    );

    setState(() {
      _messageStream = newStream;
      _isLoadingMessages = false;
    });
  }

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
        alignment: WrapAlignment.start,
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
          const SizedBox(width: kIsWeb ? 10 : 80),
          Text(
            widget.selectedUser.name,
            style: GoogleFonts.comfortaa(
              fontSize: kIsWeb ? 25 : 20,
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 10),
          //SingleChildScrollView(
          /*child:*/ Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Messages
              SizedBox(
                height: kIsWeb ? 780 : 540,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(widget.receiverId),
                    child: _buildMessageList(),
                  ),
                ),
              ),
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
    if (_isLoadingMessages || _messageStream == null) {
      return Center(
        child: CircularProgressIndicator(
          color: widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      key: ValueKey(widget.receiverId),
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          );
        }

        final docs = snapshot.data?.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && _isNearBottom) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (docs == null || docs.isEmpty) {
          return Center(
            child: Text(
              'No messages to show',
              style: GoogleFonts.comfortaa(
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
                fontSize: 25,
              ),
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          children:
              docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final isMe = data['senderId'] == _firebaseAuth.currentUser!.uid;

    myUser.User senderUser =
        (data['senderEmail'] == widget.signedUser.email)
            ? widget.signedUser
            : widget.selectedUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildProfileImage(senderUser.profileImgUrl!),

          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                senderUser.userName,
                style: GoogleFonts.comfortaa(
                  fontSize: 13,
                  color:
                      widget.theme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 5),
              ChatBubble(theme: widget.theme, message: data['message']),
            ],
          ),
          if (isMe) _buildProfileImage(senderUser.profileImgUrl!),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 16,
        backgroundImage:
            (imageUrl != '')
                ? NetworkImage(imageUrl)
                : AssetImage('Images/defProfile.jpg'),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 5),
            child: TextField(
              maxLines: null,
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
        ),
        //kIsWeb
        Tooltip(
          message: 'Choose and send txt simulation file',
          textStyle: GoogleFonts.comfortaa(
            backgroundColor:
                widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            color: widget.theme ? Colors.white : darkBg,
          ),
          child: IconButton(
            onPressed: () {
              //todo:Handle uploading and sending txt file
            },
            icon: Icon(
              FontAwesomeIcons.file,
              size: 30,
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
        ),
        //: SizedBox(),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Send entered message',
          textStyle: GoogleFonts.comfortaa(
            backgroundColor:
                widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            color: widget.theme ? Colors.white : darkBg,
          ),
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.send,
              size: 30,
              color:
                  widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
