import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:mime/mime.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class EditProfile extends StatefulWidget {
  final User user;
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

  String _imgUrl = '';
  File? _image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
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
                child: SizedBox(
                  width: kIsWeb ? 1200 : 500,
                  height: kIsWeb ? 800 : 670,
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
                            : Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(30),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color:
                                              widget.theme
                                                  ? Colors.blue.shade600
                                                  : Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child:
                                                  _imageBytes != null
                                                      ? Image.memory(
                                                        _imageBytes!,
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : (widget
                                                                  .user
                                                                  .profileImgUrl !=
                                                              null &&
                                                          widget
                                                                  .user
                                                                  .profileImgUrl !=
                                                              '')
                                                      ? Image.network(
                                                        widget
                                                            .user
                                                            .profileImgUrl!,
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : Image.asset(
                                                        'Images/defProfile.jpg',
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
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
                                                          _imageBytes = bytes;
                                                        });
                                                      });
                                                    } else {
                                                      _showImagePicker();
                                                      await _uploadImage();
                                                    }
                                                  } catch (e) {
                                                    showSnackBar(
                                                      widget.theme,
                                                      e.toString(),
                                                    );
                                                  }
                                                },
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      widget.theme
                                                          ? Colors.white
                                                          : Colors.black,
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
                                        style: GoogleFonts.comfortaa(
                                          fontSize: 40,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(child: SizedBox(width: 10)),
                                      Text(
                                        'Ask for \"Verified account\" mark?',
                                        style: GoogleFonts.comfortaa(
                                          color:
                                              widget.theme
                                                  ? Colors.blue.shade600
                                                  : Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 30,
                                        ),
                                        child: Switch(
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
                                          inactiveTrackColor: Colors.grey[400],
                                          value: isSwitched,
                                          onChanged: (value) {
                                            setState(() {
                                              isSwitched = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildTextField(
                                        widget.theme,
                                        'Phone number: ',
                                        phone,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 120),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12),
                                          backgroundColor: const Color.fromARGB(
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
                                                    ? Colors.blue.shade600
                                                    : Colors.green.shade600,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(12),
                                          backgroundColor:
                                              widget.theme
                                                  ? Colors.blue.shade600
                                                  : Colors.black,
                                        ),
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            bool? confirmed = await showDialog(
                                              barrierDismissible: false,
                                              context: super.context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    backgroundColor:
                                                        widget.theme
                                                            ? Colors.white
                                                            : darkBg,
                                                    title: Text(
                                                      'Profile changes confirmation',
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
                                                      'Confirm changes?',
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
                                              await _submitProfileChanges(
                                                widget.user,
                                              );
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              await Future.delayed(
                                                Duration(seconds: 2),
                                              );
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              if (!kIsWeb) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => FeedPage(
                                                          user: User(
                                                            userID:
                                                                widget
                                                                    .user
                                                                    .userID,
                                                            name: name.text,
                                                            userName:
                                                                userName.text,
                                                            email: email.text,
                                                            password:
                                                                password.text,
                                                            isSignedIn: true,
                                                            isAdmin:
                                                                widget
                                                                    .user
                                                                    .isAdmin,
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
                                                        (context) => WebApp(
                                                          isSignedIn: true,
                                                          user: User(
                                                            userID:
                                                                widget
                                                                    .user
                                                                    .userID,
                                                            name: name.text,
                                                            userName:
                                                                userName.text,
                                                            email: email.text,
                                                            password:
                                                                password.text,
                                                            isSignedIn: true,
                                                            isAdmin:
                                                                widget
                                                                    .user
                                                                    .isAdmin,
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
                                                    : Colors.green.shade600,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
    );
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

    final url = Uri.parse('https://api.cloudinary.com/v1_1/ds565huxe/upload');
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

  List<User> _users = [];
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

  Future<bool> _submitProfileChanges(User x) async {
    final Map<String, dynamic> dataToSend = {
      'userID': x.userID,
      'username': userName.text,
      'name': name.text,
      'email': email.text.toLowerCase(),
      'phone': phone.text,
      'password': password.text,
      'imageUrl': (_imgUrl != '') ? _imgUrl : x.profileImgUrl,
    };
    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/user/edit')
            : Uri.parse('http://10.0.2.2:3000/user/edit');

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
