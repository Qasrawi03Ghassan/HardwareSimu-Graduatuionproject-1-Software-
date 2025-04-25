import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';

TextStyle tStyle = GoogleFonts.comfortaa(
  fontSize: 25,
  color: Colors.black,
  fontWeight: FontWeight.normal,
);

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignupPage> {
  bool isLightTheme = true;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  final TextEditingController emailController = TextEditingController();

  File? _image;
  Uint8List? _imageBytes;

  String _imgUrl = 'defU';
  String _email = 'defE';
  String _pass = 'defPass';
  String _conpass = '';
  String _username = 'defPass';
  String _fullname = 'defPass';
  String _phonenumber = 'defPass';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageWeb() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      Uint8List bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = null;
      });
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
                  color: isLightTheme ? Colors.blueAccent : Colors.white,
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
                  color: isLightTheme ? Colors.blueAccent : Colors.white,
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

  @override
  Widget build(BuildContext context) {
    isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : MediaQuery.of(context).platformBrightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: kIsWeb ? true : false,
        title: Text(
          "Sign up",
          style: TextStyle(
            fontSize: 40,
            color: isLightTheme ? Colors.white : Colors.green.shade600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isLightTheme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
        backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isLightTheme
                    ? [Colors.blue.shade600, Colors.blue.shade200]
                    : [Colors.black, const Color.fromARGB(255, 68, 71, 90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child:
                  _isLoading
                      ? CircularProgressIndicator(
                        color:
                            isLightTheme ? Colors.white : Colors.green.shade600,
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap:
                                    !kIsWeb
                                        ? _showImagePicker
                                        : _pickImageWeb, // When the user taps the circle, it picks an image
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                      (!kIsWeb)
                                          //Mobile image
                                          ? _image != null
                                              ? FileImage(_image!)
                                              : const AssetImage(
                                                    'Images/defProfile.jpg',
                                                  )
                                                  as ImageProvider
                                          //Web image
                                          : _imageBytes != null
                                          ? MemoryImage(_imageBytes!)
                                          : const AssetImage(
                                            'Images/defProfile.jpg',
                                          ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap:
                                      !kIsWeb
                                          ? _showImagePicker
                                          : _pickImageWeb, // Let users tap the pencil icon to change image
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Colors
                                              .white, // Background color for contrast
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.edit,
                                      color:
                                          isLightTheme
                                              ? Colors.blueAccent
                                              : Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Profile picture",
                            style: GoogleFonts.comfortaa(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: kIsWeb ? 40 : 3),
                          SizedBox(
                            width: kIsWeb ? 450 : 500,
                            child: Card(
                              color:
                                  isLightTheme
                                      ? Colors.white
                                      : Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Create a new Account",
                                        style: GoogleFonts.comfortaa(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isLightTheme
                                                  ? Colors.blue.shade900
                                                  : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      _buildTextField(
                                        label: "Username",
                                        icon: Icons.account_circle,
                                        onSaved: (value) => _username = value,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildTextField(
                                        label: "Full name",
                                        icon: Icons.person,
                                        onSaved: (value) => _fullname = value,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildTextField(
                                        label: "Email address",
                                        icon: Icons.email,
                                        onSaved: (value) => _email = value,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildTextField(
                                        label: "Mobile number (Optional)",
                                        icon: Icons.phone,
                                        isOptional: true,
                                        isNumeric: true,
                                        onSaved:
                                            (value) => _phonenumber = value,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildPasswordField(
                                        label: "Password",
                                        obscureText: _obscurePassword,
                                        onSaved: (value) => _pass = value,
                                        toggleObscure: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildPasswordField(
                                        label: "Confirm Password",
                                        obscureText: _obscureConfirmPassword,
                                        onSaved: (value) => _conpass = value,
                                        toggleObscure: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            if (_pass.length < 6) {
                                              showSnackBar(
                                                isLightTheme,
                                                'Password must be at least 6 characters',
                                              );
                                            } else if (_pass != _conpass) {
                                              showSnackBar(
                                                isLightTheme,
                                                'Passwords are not identical',
                                              );
                                            } else {
                                              // Handle form submission and sign up
                                              try {
                                                await FirebaseAuth.instance
                                                    .createUserWithEmailAndPassword(
                                                      email: _email.trim(),
                                                      password: _pass.trim(),
                                                    );
                                                _submitForm();
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                await Future.delayed(
                                                  Duration(seconds: 2),
                                                );
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                showSnackBar(
                                                  isLightTheme,
                                                  'User added successfully',
                                                );
                                                // got to next page
                                                if (!kIsWeb) {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              FeedPage(),
                                                    ),
                                                    (route) =>
                                                        false, // Removes all previous routes (deletes the Sign-Up Page)
                                                  );
                                                } else {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) => WebApp(
                                                            isSignedIn: true,
                                                          ),
                                                    ),
                                                    (route) =>
                                                        false, // Removes all previous routes (deletes the Sign-Up Page)
                                                  );
                                                }
                                              } on FirebaseAuthException catch (
                                                e
                                              ) {
                                                print('Error: ${e.message}');
                                                if (e.message ==
                                                    'email-already-in-use') {
                                                  showSnackBar(
                                                    isLightTheme,
                                                    'User already exists',
                                                  );
                                                } else {
                                                  showSnackBar(
                                                    isLightTheme,
                                                    'Error adding user, make sure your email is valid',
                                                  );
                                                }
                                              }
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isLightTheme
                                                  ? Colors.blueAccent
                                                  : darkBg,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                        ),
                                        child: const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onSaved,
    bool isOptional = false,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: (label.contains('Email address')) ? emailController : null,
      style: TextStyle(color: isLightTheme ? Colors.black : Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isLightTheme ? Colors.black : Colors.white,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: isLightTheme ? Colors.black : Colors.white,
        ),
        prefixIcon: Icon(
          icon,
          color: isLightTheme ? Colors.blueAccent : darkBg,
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
                      ? (!emailValid.hasMatch(emailController.text))
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
  }) {
    return TextFormField(
      style: TextStyle(color: isLightTheme ? Colors.black : Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isLightTheme ? Colors.black : Colors.white,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: isLightTheme ? Colors.black : Colors.white,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: isLightTheme ? Colors.blueAccent : darkBg,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: isLightTheme ? Colors.blueAccent : darkBg,
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

  Future<void> _uploadImage() async {
    final mimeType = lookupMimeType('', headerBytes: _imageBytes!);
    final mediaType = mimeType?.split('/');
    final fileExtension = mediaType != null ? mediaType.last : 'png';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/ds565huxe/upload');
    final request;
    if (!kIsWeb) {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..files.add(
              await http.MultipartFile.fromPath(
                'file',
                _image!.path,
                filename: 'userProfileUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    } else {
      request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'uploadPreset'
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                _imageBytes!,
                filename: 'userProfileUpload.$fileExtension',
                contentType:
                    mediaType != null
                        ? MediaType(mediaType.first, mediaType.last)
                        : MediaType('image', 'png'),
              ),
            );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();

      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        _imgUrl = jsonMap['url'];
      });
      print(_imgUrl);
    }
  }

  Future<void> _submitForm() async {
    await _uploadImage();

    final Map<String, dynamic> dataToSend = {
      'username': _username,
      'fullname': _fullname,
      'email': _email,
      'phonenumber': _phonenumber,
      'password': _pass,
      'imageUrl': _imgUrl,
    };

    final url =
        kIsWeb
            ? Uri.parse('http://localhost:3000/user/signup')
            : Uri.parse('http://10.0.2.2:3000/user/signup');

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
