import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/notificationsServices/notifsProvider.dart';
import 'package:hardwaresimu_software_graduation_project/themeMobile.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifsScreen extends StatefulWidget {
  final myUser.User? user;
  final RemoteMessage? message;

  const NotifsScreen({super.key, required this.user, required this.message});

  @override
  State<StatefulWidget> createState() => _NotifsScreenState(user: this.user);
}

class _NotifsScreenState extends State<NotifsScreen> {
  myUser.User? user;

  _NotifsScreenState({required this.user});

  bool isLightTheme = false;
  List<myUser.User> _users = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchUsers();

    // Optional: You could add the initial notification to the provider here
    /*if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notificationsProvider = Provider.of<NotificationsProvider>(
          context,
          listen: false,
        );
        notificationsProvider.addNotification(widget.message!);
      });
    }*/
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:3000/api/users',
      ), //todo change this to 192.168.88.5 for real phone
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

  @override
  Widget build(BuildContext context) {
    isLightTheme = Provider.of<MobileThemeProvider>(
      context,
    ).isLightTheme(context);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
        ),
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, child) {
          final notifications = notificationsProvider.notifications;

          final currentUid = FirebaseAuth.instance.currentUser?.uid;

          // Check if the list is empty or no message is for the current user
          if (notifications.isEmpty ||
              !notifications.any((msg) => msg.data['toUser'] == currentUid)) {
            // Show "No notifications yet"
            return Center(
              child: Text(
                'No notifications yet',
                style: GoogleFonts.comfortaa(
                  fontSize: 28,
                  color:
                      isLightTheme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final message = notifications[index];
              return buildNotif(isLightTheme, message, () {
                Provider.of<NotificationsProvider>(
                  context,
                  listen: false,
                ).removeNotification(message);
              });
            },
          );
        },
      ),
    );
  }

  Widget buildNotif(bool theme, RemoteMessage message, VoidCallback onRemove) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final toUser = message.data['toUser'];
    final senderImgUrl =
        message.notification!.title!.contains('chat')
            ? getImageUrlFromEmail(message.data['fromUserEmail'])
            : '';

    if (currentUser == null || toUser != currentUser.uid) {
      return SizedBox(); // Or just skip rendering this notification
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme ? Colors.blue.shade600 : Colors.green.shade600,
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          message.notification!.title!.contains('chat')
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                        senderImgUrl != null && senderImgUrl != ''
                            ? Image.network(
                              senderImgUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'Images/defProfile.jpg',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.notification?.title ?? "No title",
                          style: GoogleFonts.comfortaa(
                            fontSize: 18,
                            color: theme ? Colors.white : darkBg,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message.notification?.body ?? "No body",
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            color: theme ? Colors.white : darkBg,
                            fontWeight: FontWeight.w700,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme ? Colors.white : darkBg,
                      ),
                      onPressed: onRemove,
                    ),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded Column content (title + body)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.notification?.title ?? "No title",
                          style: GoogleFonts.comfortaa(
                            fontSize: 18,
                            color: theme ? Colors.white : darkBg,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          message.notification?.body ?? "No body",
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            color: theme ? Colors.white : darkBg,
                            fontWeight: FontWeight.w700,
                          ),
                          //softWrap: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // X icon
                  Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme ? Colors.white : darkBg,
                      ),
                      onPressed: onRemove,
                    ),
                  ),
                ],
              ),
    );
  }

  String? getImageUrlFromEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email).profileImgUrl;
    } catch (e) {
      return null;
    }
  }
}
