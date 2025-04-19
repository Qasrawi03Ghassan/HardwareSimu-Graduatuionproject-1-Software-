import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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
  File? _image;
  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap:
                            !kIsWeb
                                ? _showImagePicker
                                : () {}, // When the user taps the circle, it picks an image
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              _image != null
                                  ? FileImage(_image!)
                                  : const AssetImage('Images/defProfile.jpg')
                                      as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap:
                              !kIsWeb
                                  ? _showImagePicker
                                  : () {}, // Let users tap the pencil icon to change image
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.white, // Background color for contrast
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
                          isLightTheme ? Colors.white : Colors.green.shade700,
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
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                label: "Full name",
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                label: "Email address",
                                icon: Icons.email,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                label: "Mobile number (Optional)",
                                icon: Icons.phone,
                                isOptional: true,
                                isNumeric: true,
                              ),
                              const SizedBox(height: 15),
                              _buildPasswordField(
                                label: "Password",
                                obscureText: _obscurePassword,
                                toggleObscure: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              _buildPasswordField(
                                label: "Confirm Password",
                                obscureText: _obscureConfirmPassword,
                                toggleObscure: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Handle form submission and sign in

                                    // got to next page
                                    if (!kIsWeb) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FeedPage(),
                                        ),
                                        (route) =>
                                            false, // Removes all previous routes (deletes the Sign-Up Page)
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  WebApp(isSignedIn: true),
                                        ),
                                        (route) =>
                                            false, // Removes all previous routes (deletes the Sign-Up Page)
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLightTheme ? Colors.blueAccent : darkBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
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
    );
  }
}
