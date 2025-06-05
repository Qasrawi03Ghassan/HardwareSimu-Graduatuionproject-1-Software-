import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signUp.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:mime/mime.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EditProfile extends StatefulWidget {
  final myUser.User user;
  final bool theme;
  const EditProfile({super.key, required this.theme, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController userName = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isObSecured = false;
  bool isSwitched = false;

  bool _isLoading = false;

  bool isFilePicked = false;

  String _imgUrl = '';
  File? _image;
  Uint8List? _imageBytes;

  String? fileUrl;

  int newCerID = 0;
  int newReqID = 0;
  List<Request> dbRequestsList = [];

  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  Request? getRequestFromUser(int userID) {
    try {
      return dbRequestsList.firstWhere((req) => req.userID == userID);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCers();
    _fetchReqs();
    userName.text = widget.user.userName;
    name.text = widget.user.name;
    email.text = widget.user.email;
    password.text = widget.user.password;
    phone.text = widget.user.phoneNum!;
  }

  @override
  void dispose() {
    userName.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.theme ? Colors.blue.shade600 : Colors.black,
        title: Text(
          'Edit your profile',
          style: GoogleFonts.comfortaa(
            color: widget.theme ? Colors.white : Colors.green.shade600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: widget.theme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                widget.theme
                    ? [Colors.blue.shade600, Colors.blue.shade200]
                    : [Colors.black, const Color.fromARGB(255, 68, 71, 90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: kIsWeb ? (isSwitched ? 1600 : 1200) : 500,

                  height:
                      kIsWeb
                          ? 800
                          : !isSwitched
                          ? 650
                          : 755, //750
                  child: Card(
                    color: widget.theme ? Colors.white : Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 20,
                    child:
                        _isLoading
                            ? Center(
                              child: CircularProgressIndicator(
                                color:
                                    widget.theme
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                              ),
                            )
                            : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Form(
                                    key: formKey,
                                    child:
                                        kIsWeb
                                            ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.all(
                                                        30,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            widget.theme
                                                                ? Colors
                                                                    .blue
                                                                    .shade600
                                                                : Colors.black,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              50,
                                                            ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  50,
                                                                ),
                                                            child:
                                                                _imageBytes !=
                                                                        null
                                                                    ? Image.memory(
                                                                      _imageBytes!,
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          150,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    )
                                                                    : (widget.user.profileImgUrl !=
                                                                            null &&
                                                                        widget.user.profileImgUrl !=
                                                                            '')
                                                                    ? CachedNetworkImage(
                                                                      //image.netwrok
                                                                      imageUrl:
                                                                          widget
                                                                              .user
                                                                              .profileImgUrl!,
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          150,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    )
                                                                    : Image.asset(
                                                                      'Images/defProfile.jpg',
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          150,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    ),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                try {
                                                                  if (kIsWeb) {
                                                                    _pickImageWeb((
                                                                      bytes,
                                                                    ) async {
                                                                      setState(() {
                                                                        _imageBytes =
                                                                            bytes;
                                                                      });
                                                                    });
                                                                  } else {
                                                                    _showImagePicker();
                                                                    await _uploadImage();
                                                                  }
                                                                } catch (e) {
                                                                  showSnackBar(
                                                                    widget
                                                                        .theme,
                                                                    e.toString(),
                                                                  );
                                                                }
                                                              },
                                                              child: CircleAvatar(
                                                                radius: 20,
                                                                backgroundColor:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  color:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .blue
                                                                              .shade600
                                                                          : Colors
                                                                              .green
                                                                              .shade600,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(width: 10),
                                                    Text(
                                                      widget.user.name,
                                                      style:
                                                          GoogleFonts.comfortaa(
                                                            fontSize: 40,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    if (widget.user.isVerified)
                                                      Tooltip(
                                                        message:
                                                            'Your account is verified',
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                widget.theme
                                                                    ? Colors
                                                                        .white
                                                                    : darkBg,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  100,
                                                                ),
                                                          ),
                                                          child: Image.asset(
                                                            widget.theme
                                                                ? 'Images/ver.png'
                                                                : 'Images/verDark.png',
                                                            width: 30,
                                                            height: 30,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: 10,
                                                      ),
                                                    ),
                                                    if (!widget.user.isAdmin &&
                                                        !widget
                                                            .user
                                                            .isVerified &&
                                                        getRequestFromUser(
                                                              widget
                                                                  .user
                                                                  .userID,
                                                            ) ==
                                                            null)
                                                      Expanded(
                                                        flex: 2,
                                                        child: Wrap(
                                                          children: [
                                                            RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Upload a certificate?\n\n',
                                                                    style: GoogleFonts.comfortaa(
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                      fontSize:
                                                                          25,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        'Uploading a certificate of you being a lecturer provides more credibility for your courses and marks them as verified after being approved from admins',
                                                                    style: GoogleFonts.comfortaa(
                                                                      color:
                                                                          Colors
                                                                              .black,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              widget.theme
                                                                  ? 'Images/ver.png'
                                                                  : 'Images/verDark.png',
                                                              width: 30,
                                                              height: 30,
                                                              fit:
                                                                  BoxFit
                                                                      .contain,
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                    const SizedBox(width: 5),
                                                    if ((!widget.user.isAdmin &&
                                                            !widget
                                                                .user
                                                                .isVerified) &&
                                                        getRequestFromUser(
                                                              widget
                                                                  .user
                                                                  .userID,
                                                            ) ==
                                                            null)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                            ),
                                                        child: Switch(
                                                          activeColor:
                                                              widget.theme
                                                                  ? Colors
                                                                      .blue
                                                                      .shade600
                                                                  : Colors
                                                                      .black,
                                                          activeTrackColor:
                                                              widget.theme
                                                                  ? Colors.blue
                                                                  : const Color.fromARGB(
                                                                    255,
                                                                    73,
                                                                    73,
                                                                    73,
                                                                  ),
                                                          inactiveThumbColor:
                                                              widget.theme
                                                                  ? Colors.grey
                                                                  : const Color.fromARGB(
                                                                    255,
                                                                    62,
                                                                    65,
                                                                    85,
                                                                  ),
                                                          inactiveTrackColor:
                                                              Colors.grey[400],
                                                          value: isSwitched,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isSwitched =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    if ((!widget.user.isAdmin ||
                                                            !widget
                                                                .user
                                                                .isVerified) &&
                                                        getRequestFromUser(
                                                              widget
                                                                  .user
                                                                  .userID,
                                                            ) !=
                                                            null)
                                                      Text(
                                                        'You already submitted a request',
                                                        style: GoogleFonts.comfortaa(
                                                          color:
                                                              widget.theme
                                                                  ? Colors
                                                                      .blue
                                                                      .shade600
                                                                  : Colors
                                                                      .black,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _buildTextField(
                                                      widget.theme,
                                                      'Username: ',
                                                      userName,
                                                    ),
                                                    const SizedBox(width: 130),
                                                    _buildTextField(
                                                      widget.theme,
                                                      'name: ',
                                                      name,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 100),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 40),
                                                    _buildTextField(
                                                      widget.theme,
                                                      'Email: ',
                                                      email,
                                                    ),
                                                    const SizedBox(width: 100),
                                                    _buildTextField(
                                                      widget.theme,
                                                      'Password: ',
                                                      password,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 100),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _buildTextField(
                                                      widget.theme,
                                                      'Phone number: ',
                                                      phone,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 60),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        padding: EdgeInsets.all(
                                                          12,
                                                        ),
                                                        backgroundColor:
                                                            const Color.fromARGB(
                                                              255,
                                                              110,
                                                              110,
                                                              110,
                                                            ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: GoogleFonts.comfortaa(
                                                          color:
                                                              widget.theme
                                                                  ? Colors
                                                                      .blue
                                                                      .shade600
                                                                  : Colors
                                                                      .green
                                                                      .shade600,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            backgroundColor:
                                                                widget.theme
                                                                    ? Colors
                                                                        .blue
                                                                        .shade600
                                                                    : Colors
                                                                        .black,
                                                          ),
                                                      onPressed: () async {
                                                        if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          bool?
                                                          confirmed = await showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context:
                                                                super.context,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AlertDialog(
                                                                  backgroundColor:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .white
                                                                          : darkBg,
                                                                  title: Text(
                                                                    'Profile changes confirmation',
                                                                    style: GoogleFonts.comfortaa(
                                                                      color:
                                                                          widget.theme
                                                                              ? Colors.blue.shade600
                                                                              : Colors.green.shade600,
                                                                    ),
                                                                  ),
                                                                  content: Text(
                                                                    'Confirm changes?',
                                                                    style: GoogleFonts.comfortaa(
                                                                      color:
                                                                          widget.theme
                                                                              ? Colors.blue.shade600
                                                                              : Colors.green.shade600,
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
                                                            await _submitProfileChanges(
                                                              widget.user,
                                                            );
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            await Future.delayed(
                                                              Duration(
                                                                seconds: 2,
                                                              ),
                                                            );
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                            if (!kIsWeb) {
                                                              if (_image ==
                                                                  null) {
                                                                _imgUrl =
                                                                    widget
                                                                        .user
                                                                        .profileImgUrl!;
                                                              }
                                                              Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => FeedPage(
                                                                        /*key:
                                                                            feedPageKey,*/
                                                                        selectedIndex:
                                                                            4,
                                                                        user: myUser.User(
                                                                          isVerified:
                                                                              widget.user.isVerified,
                                                                          userID:
                                                                              widget.user.userID,
                                                                          name:
                                                                              name.text,
                                                                          userName:
                                                                              userName.text,
                                                                          email:
                                                                              email.text,
                                                                          password:
                                                                              password.text,
                                                                          isSignedIn:
                                                                              true,
                                                                          isAdmin:
                                                                              widget.user.isAdmin,
                                                                          phoneNum:
                                                                              phone.text,
                                                                          profileImgUrl:
                                                                              (_imgUrl !=
                                                                                      '')
                                                                                  ? _imgUrl
                                                                                  : widget.user.profileImgUrl,
                                                                        ),
                                                                      ),
                                                                ),
                                                                (route) =>
                                                                    false, // Removes all previous routes
                                                              );
                                                            } else {
                                                              Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => WebApp(
                                                                        isSignedIn:
                                                                            true,
                                                                        user: myUser.User(
                                                                          isVerified:
                                                                              widget.user.isVerified,
                                                                          userID:
                                                                              widget.user.userID,
                                                                          name:
                                                                              name.text,
                                                                          userName:
                                                                              userName.text,
                                                                          email:
                                                                              email.text,
                                                                          password:
                                                                              password.text,
                                                                          isSignedIn:
                                                                              true,
                                                                          isAdmin:
                                                                              widget.user.isAdmin,
                                                                          phoneNum:
                                                                              phone.text,
                                                                          profileImgUrl:
                                                                              (_imgUrl !=
                                                                                      '')
                                                                                  ? _imgUrl
                                                                                  : widget.user.profileImgUrl,
                                                                        ),
                                                                      ),
                                                                ),
                                                                (route) =>
                                                                    false, // Removes all previous routes
                                                              );
                                                            }
                                                            showSnackBar(
                                                              widget.theme,
                                                              'User information changed successfully',
                                                            );
                                                          }
                                                        }
                                                      },
                                                      child: Text(
                                                        'Submit changes',
                                                        style: GoogleFonts.comfortaa(
                                                          color:
                                                              widget.theme
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .green
                                                                      .shade600,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                            : //Center(
                                            //child: SingleChildScrollView(
                                            /*child:*/ Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 10,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      GestureDetector(
                                                        onTap:
                                                            _showImagePicker, // When the user taps the circle, it picks an image
                                                        child: CircleAvatar(
                                                          radius: 40,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          backgroundImage:
                                                              _image != null
                                                                  ? FileImage(
                                                                    _image!,
                                                                  )
                                                                  : widget.user.profileImgUrl !=
                                                                          null &&
                                                                      widget.user.profileImgUrl !=
                                                                          ''
                                                                  ? NetworkImage(
                                                                    widget
                                                                        .user
                                                                        .profileImgUrl!,
                                                                  )
                                                                  : AssetImage(
                                                                    'Images/defProfile.jpg',
                                                                  ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap:
                                                              _showImagePicker, // Let users tap the pencil icon to change image
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color:
                                                                  widget.theme
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black, // Background color for contrast
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color:
                                                                      Colors
                                                                          .black26,
                                                                  blurRadius: 4,
                                                                  offset:
                                                                      Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  5,
                                                                ),
                                                            child: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  widget.theme
                                                                      ? Colors
                                                                          .blueAccent
                                                                      : Colors
                                                                          .black,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "Profile picture",
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              widget.theme
                                                                  ? Colors
                                                                      .blue
                                                                      .shade600
                                                                  : Colors
                                                                      .white,
                                                        ),
                                                  ),
                                                  //const SizedBox(height: 5),
                                                  SizedBox(
                                                    width: 500,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            0,
                                                          ),
                                                      child: Form(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              "Edit your account details",
                                                              style: GoogleFonts.comfortaa(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blue
                                                                            .shade600
                                                                        : Colors
                                                                            .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            _buildMobileTextField(
                                                              label: "Username",
                                                              icon:
                                                                  Icons
                                                                      .account_circle,
                                                              onSaved:
                                                                  (value) =>
                                                                      userName.text =
                                                                          value,
                                                              cont: userName,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            _buildMobileTextField(
                                                              label:
                                                                  "Full name",
                                                              icon:
                                                                  Icons.person,
                                                              onSaved:
                                                                  (value) =>
                                                                      name.text =
                                                                          value,
                                                              cont: name,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            _buildMobileTextField(
                                                              label:
                                                                  "Email address",
                                                              icon: Icons.email,
                                                              onSaved:
                                                                  (value) =>
                                                                      email.text =
                                                                          value,
                                                              cont: email,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            _buildMobileTextField(
                                                              label:
                                                                  "Mobile number (Optional)",
                                                              icon: Icons.phone,
                                                              isOptional: true,
                                                              isNumeric: true,
                                                              onSaved:
                                                                  (value) =>
                                                                      phone.text =
                                                                          value,
                                                              cont: phone,
                                                            ),
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                            _buildPasswordField(
                                                              label: "Password",
                                                              obscureText:
                                                                  !_isObSecured,
                                                              onSaved:
                                                                  (value) =>
                                                                      password.text =
                                                                          value,
                                                              cont: password,
                                                              toggleObscure: () {
                                                                setState(() {
                                                                  _isObSecured =
                                                                      !_isObSecured;
                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            if ((!widget
                                                                        .user
                                                                        .isAdmin &&
                                                                    !widget
                                                                        .user
                                                                        .isVerified) &&
                                                                getRequestFromUser(
                                                                      widget
                                                                          .user
                                                                          .userID,
                                                                    ) ==
                                                                    null)
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          30,
                                                                    ),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Upload a certificate?',
                                                                      style: GoogleFonts.comfortaa(
                                                                        color:
                                                                            widget.theme
                                                                                ? Colors.blue.shade600
                                                                                : Colors.white,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Switch(
                                                                      activeColor:
                                                                          widget.theme
                                                                              ? Colors.blue.shade600
                                                                              : Colors.black,
                                                                      activeTrackColor:
                                                                          widget.theme
                                                                              ? Colors.blue
                                                                              : const Color.fromARGB(
                                                                                255,
                                                                                73,
                                                                                73,
                                                                                73,
                                                                              ),
                                                                      inactiveThumbColor:
                                                                          widget.theme
                                                                              ? Colors.grey
                                                                              : const Color.fromARGB(
                                                                                255,
                                                                                62,
                                                                                65,
                                                                                85,
                                                                              ),
                                                                      inactiveTrackColor:
                                                                          Colors
                                                                              .grey[400],
                                                                      value:
                                                                          isSwitched,
                                                                      onChanged: (
                                                                        value,
                                                                      ) {
                                                                        setState(() {
                                                                          isSwitched =
                                                                              value;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if ((!widget
                                                                        .user
                                                                        .isAdmin ||
                                                                    !widget
                                                                        .user
                                                                        .isVerified) &&
                                                                getRequestFromUser(
                                                                      widget
                                                                          .user
                                                                          .userID,
                                                                    ) !=
                                                                    null)
                                                              Text(
                                                                'You already submitted a request',
                                                                style: GoogleFonts.comfortaa(
                                                                  fontSize: 17,
                                                                  color:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .blue
                                                                              .shade600
                                                                          : Colors
                                                                              .black,
                                                                ),
                                                              ),
                                                            if (widget
                                                                .user
                                                                .isVerified)
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                if (formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  bool?
                                                                  confirmed = await showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        super
                                                                            .context,
                                                                    builder:
                                                                        (
                                                                          context,
                                                                        ) => AlertDialog(
                                                                          backgroundColor:
                                                                              widget.theme
                                                                                  ? Colors.white
                                                                                  : darkBg,
                                                                          title: Text(
                                                                            'Profile changes confirmation',
                                                                            style: GoogleFonts.comfortaa(
                                                                              color:
                                                                                  widget.theme
                                                                                      ? Colors.blue.shade600
                                                                                      : Colors.green.shade600,
                                                                            ),
                                                                          ),
                                                                          content: Text(
                                                                            'Confirm changes?',
                                                                            style: GoogleFonts.comfortaa(
                                                                              color:
                                                                                  widget.theme
                                                                                      ? Colors.blue.shade600
                                                                                      : Colors.green.shade600,
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
                                                                    await _submitProfileChanges(
                                                                      widget
                                                                          .user,
                                                                    );
                                                                    setState(() {
                                                                      _isLoading =
                                                                          true;
                                                                    });
                                                                    await Future.delayed(
                                                                      Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                    );
                                                                    setState(() {
                                                                      _isLoading =
                                                                          false;
                                                                    });
                                                                    if (!kIsWeb) {
                                                                      if (_image ==
                                                                          null) {
                                                                        _imgUrl =
                                                                            widget.user.profileImgUrl!;
                                                                      }
                                                                      Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) => FeedPage(
                                                                                /*key:
                                                                                    feedPageKey,*/
                                                                                selectedIndex:
                                                                                    4,
                                                                                user: myUser.User(
                                                                                  userID:
                                                                                      widget.user.userID,
                                                                                  name:
                                                                                      name.text,
                                                                                  userName:
                                                                                      userName.text,
                                                                                  email:
                                                                                      email.text,
                                                                                  password:
                                                                                      password.text,
                                                                                  isSignedIn:
                                                                                      true,
                                                                                  isAdmin:
                                                                                      widget.user.isAdmin,
                                                                                  phoneNum:
                                                                                      phone.text,
                                                                                  profileImgUrl:
                                                                                      (_imgUrl !=
                                                                                              '')
                                                                                          ? _imgUrl
                                                                                          : widget.user.profileImgUrl,
                                                                                  isVerified:
                                                                                      widget.user.isVerified,
                                                                                ),
                                                                              ),
                                                                        ),
                                                                        (
                                                                          route,
                                                                        ) =>
                                                                            false, // Removes all previous routes
                                                                      );
                                                                    } else {
                                                                      Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) => WebApp(
                                                                                isSignedIn:
                                                                                    true,
                                                                                user: myUser.User(
                                                                                  userID:
                                                                                      widget.user.userID,
                                                                                  name:
                                                                                      name.text,
                                                                                  userName:
                                                                                      userName.text,
                                                                                  email:
                                                                                      email.text,
                                                                                  password:
                                                                                      password.text,
                                                                                  isSignedIn:
                                                                                      true,
                                                                                  isAdmin:
                                                                                      widget.user.isAdmin,
                                                                                  phoneNum:
                                                                                      phone.text,
                                                                                  profileImgUrl:
                                                                                      (_imgUrl !=
                                                                                              '')
                                                                                          ? _imgUrl
                                                                                          : widget.user.profileImgUrl,
                                                                                  isVerified:
                                                                                      widget.user.isVerified,
                                                                                ),
                                                                              ),
                                                                        ),
                                                                        (
                                                                          route,
                                                                        ) =>
                                                                            false, // Removes all previous routes
                                                                      );
                                                                    }
                                                                    showSnackBar(
                                                                      widget
                                                                          .theme,
                                                                      'User information changed successfully',
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    widget.theme
                                                                        ? Colors
                                                                            .blueAccent
                                                                        : darkBg,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          40,
                                                                      vertical:
                                                                          15,
                                                                    ),
                                                              ),
                                                              child: const Text(
                                                                "Submit changes",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    //),
                                                  ),
                                                  if (!kIsWeb)
                                                    AnimatedContainer(
                                                      duration: Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                      width: 800,
                                                      height:
                                                          isSwitched ? 120 : 0,
                                                      child: Visibility(
                                                        child: AnimatedOpacity(
                                                          opacity:
                                                              isSwitched
                                                                  ? 1.0
                                                                  : 0.0,
                                                          duration: Duration(
                                                            milliseconds: 300,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .upload,
                                                                  size: 20,
                                                                  color:
                                                                      widget.theme
                                                                          ? Colors
                                                                              .blue
                                                                              .shade600
                                                                          : Colors
                                                                              .black,
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        widget.theme
                                                                            ? Colors.blue.shade600
                                                                            : Colors.black,
                                                                  ),
                                                                  onPressed: () {
                                                                    _pickFile();
                                                                  },
                                                                  child: Text(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    !isFilePicked
                                                                        ? "Pick a file"
                                                                        : kIsWeb &&
                                                                            fileBytes !=
                                                                                null &&
                                                                            webFileName !=
                                                                                null
                                                                        ? webFileName!
                                                                        : !kIsWeb &&
                                                                            file !=
                                                                                null &&
                                                                            mobileFileName !=
                                                                                null
                                                                        ? mobileFileName!
                                                                        : 'Invalid file',
                                                                    style: GoogleFonts.comfortaa(
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          widget.theme
                                                                              ? Colors.white
                                                                              : Colors.green.shade600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              //  ),
                                              //  ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                //if (isSwitched)
                                if (kIsWeb)
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: isSwitched && kIsWeb ? 200 : 0,
                                    child: AnimatedOpacity(
                                      opacity: isSwitched ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 300),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.upload,
                                              size: 40,
                                              color:
                                                  widget.theme
                                                      ? Colors.blue.shade600
                                                      : Colors.black,
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    widget.theme
                                                        ? Colors.blue.shade600
                                                        : Colors.black,
                                              ),
                                              onPressed: () {
                                                _pickFile();
                                              },
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                !isFilePicked
                                                    ? "Pick a file"
                                                    : kIsWeb &&
                                                        fileBytes != null &&
                                                        webFileName != null
                                                    ? webFileName!
                                                    : !kIsWeb &&
                                                        file != null &&
                                                        mobileFileName != null
                                                    ? mobileFileName!
                                                    : 'Invalid file',
                                                style: GoogleFonts.comfortaa(
                                                  fontSize: 16,
                                                  color:
                                                      widget.theme
                                                          ? Colors.white
                                                          : Colors
                                                              .green
                                                              .shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  File? file;
  Uint8List? fileBytes;
  String? webFileName;
  String? mobileFileName;

  void _pickFile() async {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      String? pickedExtension = result.files.single.extension?.toLowerCase();

      // Manual validation
      if (pickedExtension != null &&
          allowedExtensions.contains(pickedExtension)) {
        if (!kIsWeb) {
          file = File(result.files.single.path!);
          mobileFileName = result.files.single.name;
        } else {
          fileBytes = result.files.single.bytes!;
          webFileName = result.files.single.name;
        }

        setState(() {
          isFilePicked = true;
        });

        print('File picked: ${result.files.single.name}');
      } else {
        // Invalid file type
        file = null;
        fileBytes = null;
        webFileName = null;

        setState(() {
          isFilePicked = false;
        });

        print('Unsupported file type selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Please select a JPG, PNG, PDF, or DOCX file.',
                style: GoogleFonts.comfortaa(
                  fontSize: 20,
                  color: widget.theme ? Colors.white : Colors.black,
                ),
              ),
            ),
            backgroundColor:
                widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
          ),
        );
      }
    } else {
      print('User canceled file picker');
    }
  }

  Future<void> uploadFile() async {
    if (!isSwitched) {
      return;
    }
    if ((kIsWeb && fileBytes == null) || (!kIsWeb && file == null)) {
      print('⚠️ No file to upload.');
      return;
    }

    try {
      if (kIsWeb) {
        await supabase.storage
            .from('circuit-academy-files')
            .uploadBinary('certificates/$webFileName', fileBytes!);
      } else {
        await supabase.storage
            .from('circuit-academy-files')
            .upload('certificates/$mobileFileName', file!);
      }

      print(
        kIsWeb
            ? '✅ File Upload successful (Web): $webFileName'
            : '✅ File Upload successful (Mobile): $mobileFileName',
      );
      if (kIsWeb) {
        fileUrl = supabase.storage
            .from('circuit-academy-files')
            .getPublicUrl('certificates/$webFileName');
      } else {
        fileUrl = supabase.storage
            .from('circuit-academy-files')
            .getPublicUrl('certificates/$mobileFileName');
      }
      print('File URL: $fileUrl');
    } catch (e) {
      print('❌ Upload failed: $e');
    }
  }

  void setPassSee(bool x) {
    setState(() {
      _isObSecured = x;
    });
  }

  Widget _buildTextField(bool theme, String text, TextEditingController cont) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.comfortaa(
            color: theme ? Colors.blue.shade600 : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: kIsWeb ? 300 : 190,
          child: TextFormField(
            maxLength: cont == phone ? 10 : null,
            maxLengthEnforcement:
                cont == phone
                    ? MaxLengthEnforcement.enforced
                    : MaxLengthEnforcement.none,
            inputFormatters:
                cont == phone ? [FilteringTextInputFormatter.digitsOnly] : null,
            validator:
                cont != phone
                    ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field cannot be empty';
                      }
                      return null;
                    }
                    : null,
            controller: cont,
            obscureText: cont == password ? !_isObSecured : false,
            style: GoogleFonts.comfortaa(
              color: theme ? Colors.blue.shade600 : Colors.green.shade600,
            ),
            decoration: InputDecoration(
              suffixIcon:
                  cont == password
                      ? IconButton(
                        onPressed: () {
                          setState(() {
                            setPassSee(!_isObSecured);
                          });
                        },
                        icon: Icon(
                          _isObSecured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color:
                              widget.theme
                                  ? Colors.blueAccent
                                  : Colors.green.shade600,
                        ),
                      )
                      : null,
              filled: true,
              fillColor:
                  theme
                      ? const Color.fromARGB(255, 223, 220, 220)
                      : const Color.fromARGB(255, 62, 65, 85),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme ? Colors.blue.shade600 : Colors.black,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTextField({
    required String label,
    required IconData icon,
    required Function(String) onSaved,
    bool isOptional = false,
    bool isNumeric = false,
    required TextEditingController cont,
  }) {
    return TextFormField(
      controller: cont,
      style: TextStyle(color: widget.theme ? Colors.black : Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.theme ? Colors.black : Colors.white,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: widget.theme ? Colors.black : Colors.white,
        ),
        prefixIcon: Icon(
          icon,
          color: widget.theme ? Colors.blueAccent : darkBg,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType:
          isNumeric
              ? TextInputType.number
              : (label.contains("Email address")
                  ? TextInputType.emailAddress
                  : TextInputType.text),
      validator:
          isOptional
              ? null
              : (value) =>
                  (value == null || value.isEmpty)
                      ? "This field is required"
                      : (label.contains("Email address"))
                      ? (!emailValid.hasMatch(email.text))
                          ? 'Please enter a valid email address'
                          : null
                      : null,
      inputFormatters:
          isNumeric
              ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
              : [],
      onSaved: (value) => onSaved(value ?? ''),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required Function(String) onSaved,
    required VoidCallback toggleObscure,
    required TextEditingController cont,
  }) {
    return TextFormField(
      controller: cont,
      style: TextStyle(color: widget.theme ? Colors.black : Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.theme ? Colors.black : Colors.white,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: widget.theme ? Colors.black : Colors.white,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: widget.theme ? Colors.blueAccent : darkBg,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.theme ? Colors.blueAccent : darkBg,
          ),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              (value == null || value.isEmpty)
                  ? "This field is required"
                  : null,
      onSaved: (value) => onSaved(value ?? ''),
    );
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageWeb(Function(Uint8List) onImagePicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Uint8List bytes = await picked.readAsBytes();
      onImagePicked(bytes);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    final mimeType =
        kIsWeb
            ? lookupMimeType('', headerBytes: _imageBytes)
            : lookupMimeType(_image!.path);
    final mediaType = mimeType?.split('/');
    final fileExtension = mediaType != null ? mediaType.last : 'png';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfjtstpjc/upload');
    final http.MultipartRequest? request;
    if (!kIsWeb && _image != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsImagesFolder'
            ..files.add(
              await http.MultipartFile.fromPath(
                'file',
                _image!.path,
                filename: 'postImageUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    } else if (_imageBytes != null) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..fields['folder'] = 'postsImagesFolder'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                _imageBytes!,
                filename: 'postImageUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    } else {
      request = null;
    }
    if (request != null) {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();

        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        //If the image doesn't go to server remove these comment
        //if (!mounted) return;
        setState(() {
          _imgUrl = jsonMap['url'];
        });
        //print(_imgUrl);
      }
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

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: widget.theme ? Colors.blueAccent : Colors.white,
                ),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: widget.theme ? Colors.blueAccent : Colors.white,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Certificate> Certificates = [];
  Future<void> _fetchCers() async {
    final response = await http.get(
      Uri.parse('http://$serverUrl:3000/api/cers'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        Certificates = json.map((item) => Certificate.fromJson(item)).toList();
      });
      if (Certificates.isNotEmpty) {
        final maxID = Certificates.map(
          (c) => c.id,
        ).reduce((a, b) => a > b ? a : b);
        newCerID = maxID + 1;
      } else {
        newCerID = 1; // start from 1 if list is empty
      }
    } else {
      throw Exception('Failed to load certificates');
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
      if (dbRequestsList.isNotEmpty) {
        final maxID = dbRequestsList
            .map((c) => c.id)
            .reduce((a, b) => a > b ? a : b);
        newReqID = maxID + 1;
      } else {
        newReqID = 1; // start from 1 if list is empty
      }
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Future<void> _submitCertificate(Certificate x) async {
    final Map<String, dynamic> dataToSend = {
      'id': x.id,
      'userID': x.userID,
      'fileUrl': x.URL,
    };

    final url = Uri.parse('http://$serverUrl:3000/certificate/create');

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

  Future<void> createNewRequest(Request x) async {
    final Map<String, dynamic> dataToSend = {
      'id': x.id,
      'userID': x.userID,
      'cerID': x.cerID,
    };

    final url = Uri.parse('http://$serverUrl:3000/reqs/create');

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

  Future<bool> _submitProfileChanges(myUser.User x) async {
    if (isSwitched &&
        ((kIsWeb && fileBytes != null) || (!kIsWeb && file != null))) {
      await uploadFile();
      await _submitCertificate(
        Certificate(id: newCerID + 1, userID: widget.user.userID, URL: fileUrl),
      );
      await createNewRequest(
        Request(id: newReqID++, userID: widget.user.userID, cerID: newCerID),
      );
      newCerID++;
    } else {
      print('Upload failed: Null files or not switched');
    }

    final Map<String, dynamic> dataToSend = {
      'userID': x.userID,
      'username': userName.text,
      'name': name.text,
      'email': email.text.toLowerCase(),
      'phone': phone.text,
      'password': password.text,
      'imageUrl': (_imgUrl != '') ? _imgUrl : x.profileImgUrl,
    };
    final url = Uri.parse('http://$serverUrl:3000/user/edit');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToSend),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
        return true;
      } else if (response.statusCode == 404) {
        print('User not found: ${response.body}');
        return false;
      } else if (response.statusCode == 401) {
        print('Wrong data: ${response.body}');
        return false;
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }
}
