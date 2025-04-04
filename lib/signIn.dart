import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hardwaresimu_software_graduation_project/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/forgotPage.dart';
import 'package:hardwaresimu_software_graduation_project/welcome.dart';

TextStyle tStyle = GoogleFonts.comfortaa(
    fontSize: 25, color: Colors.black, fontWeight: FontWeight.normal);

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

  @override
  Widget build(BuildContext context) {
    bool isLightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign in",
          style: TextStyle(fontSize: 40),
        ),
        //backgroundColor: Colors.blue.shade600,
        iconTheme: const IconThemeData(color: Colors.white, size: 35),
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLightTheme
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
                child: Card(
                  color: isLightTheme ? Colors.white : Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  colorFilter:
                                      const ColorFilter.srgbToLinearGamma(),
                                  image: isLightTheme
                                      ? const AssetImage('Images/login2.png')
                                      : const AssetImage('Images/login3.png'),
                                  fit: BoxFit.cover)),
                        ),
                        Text('Welcome Back',
                            style: GoogleFonts.comfortaa(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: isLightTheme
                                    ? Colors.blue.shade900
                                    : Colors.white)),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_circle,
                                      color: isLightTheme
                                          ? Colors.blue.shade800
                                          : darkBg),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "This field is required"
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
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
                                        color: isLightTheme
                                            ? Colors.blueAccent
                                            : darkBg,
                                      )),
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock,
                                      color: isLightTheme
                                          ? Colors.blue.shade800
                                          : darkBg),
                                ),
                                obscureText: _isObscured,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "This field is required"
                                        : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    //implement sign in here

                                    //Go to Feed page
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FeedPage()),
                                      (route) =>
                                          false, // Removes all previous routes (deletes the Sign-Up Page)
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLightTheme
                                      ? Colors.blue.shade800
                                      : darkBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        // TextField(
                        //   controller: emailController,
                        //   decoration: InputDecoration(
                        //     labelText: 'Username',
                        //     border: const OutlineInputBorder(),
                        //     prefixIcon: Icon(Icons.account_circle,
                        //         color: isLightTheme
                        //             ? Colors.blue.shade800
                        //             : darkBg),
                        //   ),
                        //   keyboardType: TextInputType.emailAddress,
                        // ),
                        // const SizedBox(height: 15),
                        // TextField(
                        //   controller: passwordController,
                        //   decoration: InputDecoration(
                        //     suffixIcon: IconButton(
                        //         onPressed: () {
                        //           setState(() {
                        //             _isObscured = !_isObscured;
                        //           });
                        //         },
                        //         icon: Icon(
                        //           _isObscured
                        //               ? Icons.visibility_off
                        //               : Icons.visibility,
                        //           color:
                        //               isLightTheme ? Colors.blueAccent : darkBg,
                        //         )),
                        //     labelText: 'Password',
                        //     border: const OutlineInputBorder(),
                        //     prefixIcon: Icon(Icons.lock,
                        //         color: isLightTheme
                        //             ? Colors.blue.shade800
                        //             : darkBg),
                        //   ),
                        //   obscureText: _isObscured,
                        // ),
                        // const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     //Go to Feed page
                        //     Navigator.pushAndRemoveUntil(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => FeedPage()),
                        //       (route) =>
                        //           false, // Removes all previous routes (deletes the Sign-Up Page)
                        //     );
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor:
                        //         isLightTheme ? Colors.blue.shade800 : darkBg,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 40, vertical: 15),
                        //   ),
                        //   child: const Text(
                        //     'Sign In',
                        //     style: TextStyle(fontSize: 18, color: Colors.white),
                        //   ),
                        // ),
                        // const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPage()));
                          },
                          child: Text('Forgot Password?',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightTheme
                                      ? Colors.blue.shade700
                                      : darkBg)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ))),
    );
  }
}
