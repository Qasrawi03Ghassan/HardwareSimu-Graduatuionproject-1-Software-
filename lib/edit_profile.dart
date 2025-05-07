import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';

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

  bool _isObSecured = false;
  bool isSwitched = false;

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
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child:
                                        (widget.user.profileImgUrl != null &&
                                                widget.user.profileImgUrl != '')
                                            ? Image.network(
                                              widget.user.profileImgUrl!,
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(
                                              'Images/defProfile.jpg',
                                              fit: BoxFit.cover,
                                              width: 150,
                                              height: 150,
                                            ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {},
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
                                                  ? Colors.blue.shade600
                                                  : Colors.green.shade600,
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
                              'Request account verification?',
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
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Switch(
                                activeColor:
                                    widget.theme
                                        ? Colors.blue.shade600
                                        : Colors.black,
                                activeTrackColor:
                                    widget.theme
                                        ? Colors.blue
                                        : const Color.fromARGB(255, 73, 73, 73),
                                inactiveThumbColor:
                                    widget.theme
                                        ? Colors.grey
                                        : const Color.fromARGB(255, 62, 65, 85),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTextField(
                              widget.theme,
                              'Username: ',
                              userName,
                            ),
                            const SizedBox(width: 130),
                            _buildTextField(widget.theme, 'name: ', name),
                          ],
                        ),
                        const SizedBox(height: 100),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 40),
                            _buildTextField(widget.theme, 'Email: ', email),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              onPressed: () {},
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
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
}
