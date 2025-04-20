import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/signIn.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  _ForgotPage createState() => _ForgotPage();
}

class _ForgotPage extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();

  String _email = 'defE';
  String _code = 'defC';
  String _newPass = 'defNP';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  bool _isEmailVisible = true;
  bool _goToCode = false;

  bool _isCodeVisible = false;
  bool _goToChange = false;

  bool _isChangeVisible = false;

  bool _isObscured = true;

  String codeSent = 'Recover your account';

  bool barTheme = true;

  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        kIsWeb
            ? context.watch<SysThemes>().isLightTheme
            : MediaQuery.of(context).platformBrightness == Brightness.light;
    barTheme = isLightTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
        iconTheme: IconThemeData(
          color: isLightTheme ? Colors.white : Colors.green.shade600,
          size: 35,
        ),
        title: Text(
          "Password recovery",
          style: GoogleFonts.comfortaa(
            fontSize: 30,
            color: isLightTheme ? Colors.white : Colors.green.shade600,
          ),
        ),
      ),
      //backgroundColor: isLightTheme ? Colors.blue.shade600 : Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isLightTheme
                    ? [Colors.blue.shade600, Colors.blue.shade100]
                    : [Colors.black, const Color.fromARGB(255, 68, 71, 90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: kIsWeb ? 700 : 600,
            width: kIsWeb ? 500 : 350,
            child: Card(
              elevation: 20,
              color: isLightTheme ? Colors.white : Colors.green.shade600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: kIsWeb ? 80 : 50),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        codeSent,
                        style: GoogleFonts.comfortaa(
                          fontSize: kIsWeb ? 35 : 25,
                          color: isLightTheme ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      isLightTheme
                          ? 'Images/recovery.png'
                          : 'Images/recoverydark.png',
                      width: kIsWeb ? 350 : 300,
                      fit: BoxFit.cover,
                    ),

                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Visibility(
                              visible: _isEmailVisible,
                              child: TextFormField(
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
                                keyboardType: TextInputType.emailAddress,
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? "This field is required"
                                            : (!emailValid.hasMatch(
                                              emailController.text,
                                            ))
                                            ? "Please enter a valid email address"
                                            : null,
                                onSaved: (value) => _email = value!,
                              ),
                            ),
                            Visibility(
                              visible: _isCodeVisible,
                              child: TextFormField(
                                style: TextStyle(
                                  color:
                                      isLightTheme
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          isLightTheme
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                  ),
                                  labelText: 'Enter the received code here',
                                  labelStyle: TextStyle(
                                    color:
                                        isLightTheme
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.code,
                                    color:
                                        isLightTheme
                                            ? Colors.blue.shade800
                                            : darkBg,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator:
                                    (value) =>
                                        (value == null || value.isEmpty)
                                            ? "This field is required"
                                            : null,
                                onSaved: (value) => _code = value!,
                              ),
                            ),
                            Visibility(
                              visible: _isChangeVisible,
                              child: TextFormField(
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
                                  labelText: 'Enter new password here',
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
                                        (value == null || value.isEmpty)
                                            ? "This field is required"
                                            : null,
                                onSaved: (value) => _newPass = value!,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Visibility(
                              visible: _isEmailVisible,
                              child: ElevatedButton(
                                onPressed: () async {
                                  //implement code sending and show code textfield here
                                  await _submitForm('email');
                                  if (_goToCode) {
                                    setState(() {
                                      _isEmailVisible = false;
                                      _isCodeVisible = true;
                                      _isChangeVisible = false;
                                      codeSent = 'Code sent successfully';
                                    });
                                  } else {
                                    showSnackBar(0);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLightTheme
                                          ? Colors.blue.shade800
                                          : darkBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Send code',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _isCodeVisible,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    //implement Checking code and make change password visible here
                                    await _submitForm('code');
                                    setState(() {
                                      if (_goToChange) {
                                        _isCodeVisible = false;
                                        _isChangeVisible = true;
                                        codeSent = 'Set a new password';
                                      } else {
                                        showSnackBar(1);
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLightTheme
                                          ? Colors.blue.shade800
                                          : darkBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Check code',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _isChangeVisible,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _submitForm('newPass');
                                  showSnackBar(2);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SigninPage(),
                                    ),
                                    (route) =>
                                        false, // Removes all previous routes (deletes the Sign-Up Page)
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLightTheme
                                          ? Colors.blue.shade800
                                          : darkBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  void showSnackBar(int state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        showCloseIcon: true,
        closeIconColor: barTheme ? Colors.white : Colors.green.shade600,
        backgroundColor: barTheme ? Colors.blue.shade600 : Colors.black,
        content: Center(
          child: Text(
            state == 0
                ? 'User not found, you can register at the sign up page'
                : state == 1
                ? 'Invalid code, try again'
                : 'Password changed successfully',
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

  Future<void> _submitForm(String jData) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form data

      final url =
          kIsWeb
              ? Uri.parse('http://localhost:3000/data')
              : Uri.parse('http://10.0.2.2:3000/data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            jData:
                (jData == 'email')
                    ? _email
                    : (jData == 'code')
                    ? _code
                    : _newPass,
          }),
        );

        if (response.statusCode == 200) {
          _goToCode = true;
          _goToChange = true;
          print('Data sent successfully: ${response.body}');
        } else if (response.statusCode == 404) {
          _goToCode = false;
          print('User not found: ${response.body}');
        } else if (response.statusCode == 401) {
          _goToChange = false;
          print('Wrong data: ${response.body}');
        } else {
          _goToCode = false;
          _goToChange = false;
          throw Exception('Failed to send data: ${response.statusCode}');
        }
      } catch (error) {
        _goToCode = false;
        _goToChange = false;
        print('Error: $error');
      }
    }
  }
}
