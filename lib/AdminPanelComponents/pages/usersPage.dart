import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireUser;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class UsersPage extends StatefulWidget {
  final bool theme;
  final User user;
  const UsersPage({super.key, required this.theme, required this.user});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> dbUsersList = [];
  List<Certificate> dbCersList = [];
  List<Request> dbRequestsList = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchCers();
    _fetchReqs();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _fetchCers() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/cers'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCersList = json.map((item) => Certificate.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load certificates');
    }
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/users'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbUsersList = json.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchReqs() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/reqs'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbRequestsList = json.map((item) => Request.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Certificate? getCerFileFromRequest(int reqID) {
    try {
      return dbCersList.firstWhere((cer) => cer.id == reqID);
    } catch (_) {
      return null;
    }
  }

  User? getUserFromRequest(int reqID) {
    try {
      return dbUsersList.firstWhere((user) => user.userID == reqID);
    } catch (_) {
      return null;
    }
  }

  int getOnlineUsersNum() {
    return dbUsersList.where((user) => user.isSignedIn).toList().length;
  }

  int getVerUsers() {
    return dbUsersList
        .where((user) => user.isVerified && !user.isAdmin)
        .toList()
        .length;
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        _fetchUsers();
        _fetchCers();
        _fetchReqs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Online users',
        'count': getNonAdminOnlineUsers(),
        'icon': Stack(
          children: [
            const Icon(Icons.people, size: 50, color: Colors.grey),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green, // online status
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),

        'color': Colors.blue,
      },
      {
        'label': 'Verified users',
        'count': getVerUsers(),
        'icon': Icons.verified,
        'color': Colors.orange,
      },
      {
        'label': 'Pending requests',
        'count': dbRequestsList.length,
        'icon': Icons.pending,
        'color': Colors.purple,
      },
    ];

    final cardColor =
        widget.theme
            ? Colors.blue.shade600
            : const Color.fromARGB(255, 67, 70, 92);
    final textColor = widget.theme ? Colors.white : Colors.green.shade600;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children:
                  stats.map((stat) {
                    return Container(
                      width: 420,
                      height: 150,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                widget.theme ? Colors.white : Colors.grey[100],
                            child:
                                stat['icon'] is IconData
                                    ? Icon(
                                      stat['icon'],
                                      color: stat['color'],
                                      size: 50,
                                    )
                                    : stat['icon'],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat['count'].toString(),
                                style: GoogleFonts.comfortaa(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                stat['label'],
                                style: GoogleFonts.comfortaa(
                                  fontSize: 30,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          //Pending table
          dbRequestsList.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Pending requests',
                        style: GoogleFonts.comfortaa(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.theme
                                  ? Colors.blue.shade600
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 500,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          dataRowMinHeight: 50,
                          dataRowMaxHeight: 150,
                          columns: [
                            DataColumn(
                              label: Center(
                                child: Text(
                                  style: GoogleFonts.comfortaa(),
                                  'Request ID',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'User\'s name',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'User\'s email',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'User\'s phone number',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'Provided certificate file URL',
                                    style: GoogleFonts.comfortaa(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Center(
                                  child: Text(
                                    'Approve or decline',
                                    style: GoogleFonts.comfortaa(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows:
                              (dbRequestsList.toList()
                                    ..sort((a, b) => b.id.compareTo(a.id)))
                                  .map(
                                    (req) => DataRow(
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(req.id.toString()),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              style: GoogleFonts.comfortaa(),
                                              getUserFromRequest(
                                                req.userID,
                                              )!.name,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              style: GoogleFonts.comfortaa(),
                                              getUserFromRequest(
                                                req.userID,
                                              )!.email,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              style: GoogleFonts.comfortaa(),
                                              getUserFromRequest(
                                                        req.userID,
                                                      )!.phoneNum! !=
                                                      ''
                                                  ? getUserFromRequest(
                                                    req.userID,
                                                  )!.phoneNum!
                                                  : 'N/A',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: SizedBox(
                                                width: 300,
                                                child: GestureDetector(
                                                  onTap:
                                                      () => _launchURL(
                                                        getCerFileFromRequest(
                                                          req.cerID,
                                                        )!.URL!,
                                                      ),
                                                  child: SelectableText.rich(
                                                    textAlign: TextAlign.center,
                                                    TextSpan(
                                                      text:
                                                          getCerFileFromRequest(
                                                                    req.cerID,
                                                                  ) !=
                                                                  null
                                                              ? getCerFileFromRequest(
                                                                req.cerID,
                                                              )!.URL!
                                                              : 'Not available',
                                                      style:
                                                          GoogleFonts.comfortaa(
                                                            color: Colors.blue,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.blue,
                                                          ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              final url = Uri.parse(
                                                                getCerFileFromRequest(
                                                                  req.cerID,
                                                                )!.URL!,
                                                              );
                                                              launchUrl(
                                                                url,
                                                                mode:
                                                                    LaunchMode
                                                                        .externalApplication,
                                                              );
                                                            },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    bool?
                                                    confirmed = await showDialog(
                                                      context: context,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => AlertDialog(
                                                            title: Text(
                                                              'Confirm request approval',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                            content: Text(
                                                              'Approve request with id ${req.id}?',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                                child: Text(
                                                                  'No',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                                child: Text(
                                                                  'Yes',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (confirmed!) {
                                                      //todo handle user notifications for approval
                                                      await submitVerifyUser(
                                                        getUserFromRequest(
                                                          req.userID,
                                                        )!,
                                                      );

                                                      await submitSendApproveNotif(
                                                        getUserFromRequest(
                                                          req.userID,
                                                        ),
                                                      );

                                                      await deleteRequest(req);
                                                      setState(() {
                                                        _fetchReqs();
                                                      });
                                                      showSnackBar(
                                                        widget.theme,
                                                        'Request with id ${req.id} was approved successfully',
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            widget.theme
                                                                ? Colors
                                                                    .blue
                                                                    .shade600
                                                                : Colors
                                                                    .green
                                                                    .shade600,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 3,
                                                              horizontal: 10,
                                                            ),
                                                      ),
                                                  child: Text(
                                                    'Approve',
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          color:
                                                              widget.theme
                                                                  ? Colors.white
                                                                  : darkBg,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    bool?
                                                    confirmed = await showDialog(
                                                      context: context,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => AlertDialog(
                                                            title: Text(
                                                              'Confirm request declination',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                            content: Text(
                                                              'Decline request with id ${req.id}?',
                                                              style: GoogleFonts.comfortaa(
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                                child: Text(
                                                                  'No',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                                child: Text(
                                                                  'Yes',
                                                                  style: GoogleFonts.comfortaa(
                                                                    color:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.green.shade600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    if (confirmed!) {
                                                      //todo handle user notifications decline
                                                      await deleteRequest(req);
                                                      setState(() {
                                                        _fetchReqs();
                                                      });

                                                      await submitSendDeclineNotif(
                                                        getUserFromRequest(
                                                          req.userID,
                                                        ),
                                                      );

                                                      showSnackBar(
                                                        widget.theme,
                                                        'Request with id ${req.id} was declined successfully',
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 3,
                                                              horizontal: 10,
                                                            ),
                                                      ),
                                                  child: Text(
                                                    'Decline',
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          color:
                                                              widget.theme
                                                                  ? Colors.white
                                                                  : darkBg,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(
                  'No pending requests',
                  style: GoogleFonts.comfortaa(
                    fontSize: 30,
                    color:
                        widget.theme
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                  ),
                ),
              ),
          const SizedBox(height: 30),
          //Users table
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Users information',
                    style: GoogleFonts.comfortaa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.theme ? Colors.blue.shade600 : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 500,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      dataRowMinHeight: 50,
                      dataRowMaxHeight: 150,
                      //columnSpacing: 20,
                      columns: [
                        DataColumn(
                          label: Center(
                            child: Text(
                              'ID',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Name',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Username',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Email address',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Password',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Phone number',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Online status',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Verification status',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Delete user',
                              style: GoogleFonts.comfortaa(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows:
                          dbUsersList
                              .where((user) => !user.isAdmin)
                              .map(
                                (user) => DataRow(
                                  cells: [
                                    DataCell(
                                      Center(
                                        child: Text(user.userID.toString()),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.name,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.userName,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.email,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.password,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.phoneNum != null &&
                                                  user.phoneNum != ''
                                              ? user.phoneNum!
                                              : 'N/A',
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.isSignedIn
                                              ? 'Online'
                                              : 'Offline',
                                          style: GoogleFonts.comfortaa(
                                            color:
                                                user.isSignedIn
                                                    ? Colors.green
                                                    : Colors.grey,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          user.isVerified
                                              ? 'Verified'
                                              : 'Not verified',
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            bool? confirmed = await showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text(
                                                      'Confirm user deletion',
                                                      style: GoogleFonts.comfortaa(
                                                        color:
                                                            widget.theme
                                                                ? Colors
                                                                    .blue
                                                                    .shade600
                                                                : Colors
                                                                    .green
                                                                    .shade600,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Delete user with id ${user.userID}?',
                                                      style: GoogleFonts.comfortaa(
                                                        color:
                                                            widget.theme
                                                                ? Colors
                                                                    .blue
                                                                    .shade600
                                                                : Colors
                                                                    .green
                                                                    .shade600,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: Text(
                                                          'No',
                                                          style: GoogleFonts.comfortaa(
                                                            color:
                                                                widget.theme
                                                                    ? Colors
                                                                        .blue
                                                                        .shade600
                                                                    : Colors
                                                                        .green
                                                                        .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: Text(
                                                          'Yes',
                                                          style: GoogleFonts.comfortaa(
                                                            color:
                                                                widget.theme
                                                                    ? Colors
                                                                        .blue
                                                                        .shade600
                                                                    : Colors
                                                                        .green
                                                                        .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (confirmed!) {
                                              await submitDeleteUser(user);
                                              setState(() {
                                                _fetchUsers();
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          label: Icon(
                                            FontAwesomeIcons.trash,
                                            color:
                                                widget.theme
                                                    ? Colors.white
                                                    : darkBg,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> getUidByEmail(String email) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        // Get the document ID (which is the uid)
        return snapshot.docs.first.id;
      } else {
        print('No user found with that email.');
        return null;
      }
    } catch (e) {
      print('Error getting uid: $e');
      return null;
    }
  }

  Future<void> submitSendApproveNotif(User? x) async {
    if (x == null) {
      print('Null user failed to send approved notif');
      return;
    }
    final approvedUserUid = await getUidByEmail(x.email);
    final Map<String, dynamic> dataToSend = {
      'uid': approvedUserUid,
      'name': x.name,
    };

    final url = Uri.parse('http://$serverUrl:3000/sendApproveNotif');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> submitSendDeclineNotif(User? x) async {
    if (x == null) {
      print('Null user failed to send decline notif');
      return;
    }
    final declinedUserUid = await getUidByEmail(x.email);
    final Map<String, dynamic> dataToSend = {
      'uid': declinedUserUid,
      'name': x.name,
    };

    final url = Uri.parse('http://$serverUrl:3000/sendDeclineNotif');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  int getNonAdminOnlineUsers() {
    return dbUsersList
        .where((user) => !user.isAdmin && user.isSignedIn)
        .toList()
        .length;
  }

  Future<void> submitDeleteUser(User x) async {
    final Map<String, dynamic> dataToSend = {'id': x.userID};

    final url = Uri.parse('http://$serverUrl:3000/user/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void showSnackBar(bool barTheme, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        showCloseIcon: true,
        closeIconColor: barTheme ? Colors.white : Colors.green.shade600,
        backgroundColor: barTheme ? Colors.blue.shade600 : Colors.black,
        content: Center(
          child: Text(
            text,
            style: GoogleFonts.comfortaa(
              fontSize: kIsWeb ? 30 : 20,
              color: barTheme ? Colors.white : Colors.green.shade600,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> submitVerifyUser(User x) async {
    final Map<String, dynamic> dataToSend = {'userID': x.userID};

    final url = Uri.parse('http://$serverUrl:3000/user/setVer');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> deleteRequest(Request x) async {
    final Map<String, dynamic> dataToSend = {'id': x.id};

    final url = Uri.parse('http://$serverUrl:3000/reqs/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
