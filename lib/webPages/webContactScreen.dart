import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WebContactScreen extends StatefulWidget {
  const WebContactScreen({super.key});

  @override
  State<WebContactScreen> createState() => _WebContactScreen();
}

class _WebContactScreen extends State<WebContactScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailCont = TextEditingController();
  TextEditingController messageCont = TextEditingController();
  final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  String _email = '';
  String _message = '';

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*Image.asset('Images/contact.png'),*/
              Text(
                'Contact us',
                style: GoogleFonts.comfortaa(
                  fontSize: 60,
                  color:
                      isLightTheme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Provide a feedback for us so we can improve more, or complain about something',
                style: GoogleFonts.comfortaa(
                  color: isLightTheme ? Colors.black : Colors.white,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 400,
                            child: TextFormField(
                              style: TextStyle(
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                              controller: emailCont,
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
                                          : Colors.green.shade600,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator:
                                  (value) =>
                                      (value == null || value.isEmpty)
                                          ? "This field is required"
                                          : (!emailValid.hasMatch(
                                            emailCont.text,
                                          ))
                                          ? "Please enter a valid email address"
                                          : null,
                              onSaved: (value) => _email = value!.toLowerCase(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 600,
                            child: TextFormField(
                              maxLines: 8,
                              style: TextStyle(
                                color:
                                    isLightTheme ? Colors.black : Colors.white,
                              ),
                              controller: messageCont,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        isLightTheme
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),

                                labelText: 'Enter message here',
                                labelStyle: TextStyle(
                                  color:
                                      isLightTheme
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                border: const OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.message,
                                  color:
                                      isLightTheme
                                          ? Colors.blue.shade800
                                          : Colors.green.shade600,
                                ),
                              ),
                              validator:
                                  (value) =>
                                      (value == null || value.isEmpty)
                                          ? "This field is required"
                                          : null,
                              onSaved: (value) => _message = value!,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isLightTheme
                                      ? Colors.blue.shade800
                                      : Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Send message',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitNewFeedBackMessage() async {
    final Map<String, dynamic> dataToSend = {
      //  'id': ,
      //  'courseID': ,
      //  'fileUrl': ,
      //  'fileName':,
    };

    final url = Uri.parse('http://localhost:3000/courseFile/create');

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
            textAlign: TextAlign.center,
            text,
            style: GoogleFonts.comfortaa(
              fontSize: 30,
              color: barTheme ? Colors.white : Colors.green.shade600,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
