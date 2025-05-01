import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;

class chatComps extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  bool isLightTheme;
  chatComps({
    super.key,
    required this.isSignedIn,
    required this.user,
    required this.isLightTheme,
  });

  @override
  State<chatComps> createState() => _chatCompsState();
}

class _chatCompsState extends State<chatComps> {
  List<User> _users = [];
  Timer? _refreshTimer;

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
        _users = json.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return chatSection(widget.isLightTheme, widget.user!);
  }

  Widget chatSection(bool theme, User user) {
    final filteredUsers = _users.where((u) => u.userID != user.userID).toList();

    filteredUsers.sort(
      (a, b) => (b.isSignedIn ? 1 : 0).compareTo(a.isSignedIn ? 1 : 0),
    );

    return ListView.separated(
      shrinkWrap: true,
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final userX = filteredUsers[index];
        return buildUser(theme, userX);
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
                  color: theme ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Container buildUser(bool theme, User user) {
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
          Text(
            user.isSignedIn ? 'Online' : 'Offline',
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              color:
                  user.isSignedIn
                      ? (theme ? Colors.blue.shade600 : Colors.green.shade600)
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
