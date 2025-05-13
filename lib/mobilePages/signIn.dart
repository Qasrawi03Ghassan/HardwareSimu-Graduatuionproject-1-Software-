import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/forgotPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:hardwaresimu_software_graduation_project/webPages/webHomeScreen.dart';
import 'package:hardwaresimu_software_graduation_project/authService.dart';
import 'package:hardwaresimu_software_graduation_project/webPages/webMainPage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

TextStyle tStyle = GoogleFonts.comfortaa(
  fontSize: 25,
  color: Colors.black,
  fontWeight: FontWeight.normal,
);

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPage createState() => _SigninPage();
}

class _SigninPage extends State<SigninPage> {
  bool _isObscured = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  String _email = 'defE';
  String _pass = 'defPass';

  bool _isLoading = false;
  bool _signIn = false;

  List<myUser.User> _users = [];

  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : MediaQuery.of(context).platformBrightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: kIsWeb ? true : false,
        title: Text(
          "Sign in",
          style: TextStyle(
            fontSize: 40,
            color: isLightTheme ? Colors.white : Colors.green.shade600,
          ),
        ),
        backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
        iconTheme: IconThemeData(
          color: isLightTheme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: kIsWeb ? 500 : 500,
                  height: kIsWeb ? 800 : 670,
                  child: Card(
                    color: isLightTheme ? Colors.white : Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child:
                          _isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade600
                                          : Colors.black,
                                ),
                              )
                              : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: kIsWeb ? 30 : 0),
                                  Container(
                                    height: kIsWeb ? 400 : 280,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        colorFilter:
                                            const ColorFilter.srgbToLinearGamma(),
                                        image:
                                            isLightTheme
                                                ? const AssetImage(
                                                  'Images/login2.png',
                                                )
                                                : const AssetImage(
                                                  'Images/login3.png',
                                                ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          isLightTheme
                                              ? Colors.blue.shade900
                                              : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          style: TextStyle(
                                            color:
                                                isLightTheme
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    isLightTheme
                                                        ? Colors.black
                                                        : Colors.white,
                                              ),
                                            ),
                                            labelText: 'Email address',
                                            labelStyle: TextStyle(
                                              color:
                                                  isLightTheme
                                                      ? Colors.black
                                                      : Colors.white,
                                            ),
                                            border: const OutlineInputBorder(),
                                            prefixIcon: Icon(
                                              Icons.email,
                                              color:
                                                  isLightTheme
                                                      ? Colors.blue.shade800
                                                      : darkBg,
                                            ),
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator:
                                              (value) =>
                                                  (value == null ||
                                                          value.isEmpty)
                                                      ? "This field is required"
                                                      : (!emailValid.hasMatch(
                                                        emailController.text,
                                                      ))
                                                      ? "Please enter a valid email address"
                                                      : null,
                                          onSaved:
                                              (value) =>
                                                  _email = value!.toLowerCase(),
                                        ),
                                        const SizedBox(height: 15),
                                        TextFormField(
                                          style: TextStyle(
                                            color:
                                                isLightTheme
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    isLightTheme
                                                        ? Colors.black
                                                        : Colors.white,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isObscured = !_isObscured;
                                                });
                                              },
                                              icon: Icon(
                                                _isObscured
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color:
                                                    isLightTheme
                                                        ? Colors.blueAccent
                                                        : darkBg,
                                              ),
                                            ),
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color:
                                                  isLightTheme
                                                      ? Colors.black
                                                      : Colors.white,
                                            ),
                                            border: const OutlineInputBorder(),
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color:
                                                  isLightTheme
                                                      ? Colors.blue.shade800
                                                      : darkBg,
                                            ),
                                          ),
                                          obscureText: _isObscured,
                                          validator:
                                              (value) =>
                                                  (value == null ||
                                                          value.isEmpty)
                                                      ? "This field is required"
                                                      : null,
                                          onSaved: (value) => _pass = value!,
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () async {
                                            //Sign in
                                            await _fetchUsers();
                                            await _submitForm();
                                            if (_signIn) {
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
                                                'Welcome back ${fetchSignedInUser(_email).name}',
                                              );
                                              //Go to Feed page
                                              if (!kIsWeb) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => FeedPage(
                                                          user:
                                                              fetchSignedInUser(
                                                                _email,
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
                                                          user:
                                                              fetchSignedInUser(
                                                                _email,
                                                              ),
                                                        ),
                                                  ),
                                                  (route) =>
                                                      false, // Removes all previous routes
                                                );
                                              }
                                              //Firebase auth for messaging
                                              final authService =
                                                  Provider.of<AuthService>(
                                                    context,
                                                    listen: false,
                                                  );
                                              try {
                                                await authService.signIn(
                                                  _email,
                                                  _pass,
                                                );
                                                // print(
                                                //   'Fire base login successful',
                                                // );
                                              } catch (e) {
                                                print('$e');
                                              }
                                              // await AuthService.signIn(
                                              //   _email,
                                              //   _pass,
                                              // );
                                            } else {
                                              showSnackBar(
                                                isLightTheme,
                                                'Invalid login credentials, make sure your email is connected to an account and the password is correct',
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isLightTheme
                                                    ? Colors.blue.shade800
                                                    : darkBg,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 15,
                                            ),
                                          ),
                                          child: const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ForgotPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isLightTheme
                                                ? Colors.blue.shade700
                                                : darkBg,
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
      ),
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

  myUser.User fetchSignedInUser(String email) {
    _fetchUsers();
    myUser.User signedUser = myUser.User(
      userID: 0,
      name: '',
      userName: '',
      email: '',
      phoneNum: '',
      password: '',
      profileImgUrl: '',
      isSignedIn: false,
      isAdmin: false,
      isVerified: false,
    );
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].email == email) {
        signedUser = _users[i];
      }
    }
    return signedUser;
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
      if (!mounted) return;
      setState(() {
        _users = json.map((item) => myUser.User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form data

      final Map<String, dynamic> dataToSend = {
        'email': _email.toLowerCase(),
        'password': _pass,
      };

      final url =
          kIsWeb
              ? Uri.parse('http://localhost:3000/user/signin')
              : Uri.parse('http://10.0.2.2:3000/user/signin');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(dataToSend),
        );

        if (response.statusCode == 200) {
          _signIn = true;
          print('Data sent successfully: ${response.body}');
        } else if (response.statusCode == 404) {
          _signIn = false;
          print('User not found: ${response.body}');
        } else if (response.statusCode == 401) {
          _signIn = false;
          print('Wrong data: ${response.body}');
        } else {
          _signIn = false;
          throw Exception('Failed to send data: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
  }
}
