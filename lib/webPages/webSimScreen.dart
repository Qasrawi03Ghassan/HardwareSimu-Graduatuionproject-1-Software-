import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/theme.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WebSimScreen extends StatefulWidget {
  final bool isSignedIn;
  final User? user;
  const WebSimScreen({super.key, required this.isSignedIn, this.user});

  @override
  State<WebSimScreen> createState() =>
      _WebSimScreenState(isSignedIn: isSignedIn, user: this.user);
}

class _WebSimScreenState extends State<WebSimScreen> {
  bool isSignedIn;
  User? user;
  _WebSimScreenState({required this.isSignedIn, this.user});
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = context.watch<SysThemes>().isLightTheme;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : darkBg,
      body: Center(child: simCont(isLightTheme)),
    );
  }

  Widget simCont(bool theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          height: 500,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            color: theme ? Colors.transparent : Colors.white,
          ),
          //width: 500,
          alignment: Alignment.center,
          child: Image.asset('Images/cct.gif', fit: BoxFit.fill),
        ),
        const SizedBox(height: 60),
        Text(
          'Try our free open source web-based simulator',
          style: GoogleFonts.comfortaa(
            color: theme ? Colors.blue.shade600 : Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 100),
            backgroundColor:
                theme ? Colors.blue.shade600 : Colors.green.shade600,
          ),
          onPressed: () async {
            final queryParams = {'isSignedIn': globalIsSignedIn.toString()};
            if (globalIsSignedIn) {
              queryParams['userEmail'] = globalSignedUser.email.toString();
            }
            final uri = Uri(
              scheme: Uri.base.scheme,
              host: Uri.base.host,
              port: Uri.base.port,
              path: '/simulator',
              queryParameters: queryParams,
            );

            if (!await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_blank', // open in a new tab on web
            )) {
              throw 'Could not launch $uri';
            }
          },
          child: Text(
            'Open simulator',
            style: GoogleFonts.comfortaa(
              fontSize: 25,
              color: theme ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
