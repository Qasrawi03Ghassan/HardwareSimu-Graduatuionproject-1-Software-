import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform; // Only import this if not building for web
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class AuthService extends ChangeNotifier {
  GoogleSignIn? _googleSignIn;

  AuthService() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _googleSignIn = GoogleSignIn();
    }
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _fireAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      rethrow;
    }
  }

  Future<myUser.User?> signInWithGitHub() async {
    try {
      // Create an OAuthProvider for GitHub
      final githubProvider = OAuthProvider("github.com");

      // Optional: Add any required GitHub scopes (e.g., access to user data)
      githubProvider.setScopes(['read:user', 'user:email']);

      // Sign in with the GitHub provider
      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        githubProvider,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      // Get the user's email
      final email = firebaseUser.email;

      // Check if the user exists in your custom backend before proceeding
      final response = await http.post(
        Uri.parse(
          kIsWeb
              ? 'http://localhost:3000/user/signin/github'
              : 'http://10.0.2.2:3000/user/signin/github',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If custom user is null or doesn't exist, return null and don't sign into Firebase
        if (data == null || data['user'] == null) {
          print("Custom user not found.");
          return null;
        }

        // Return the custom user from the backend if they exist
        return myUser.User.fromJson(data);
      } else {
        print('Server error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('GitHub sign-in error: $e');
      return null;
    }
  }

  Future<myUser.User?> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider("microsoft.com");

      // Optional: Add any scopes you need
      microsoftProvider.setScopes(['email', 'profile']);

      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        microsoftProvider,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      final email = firebaseUser.email;

      final response = await http.post(
        Uri.parse(
          kIsWeb
              ? 'http://localhost:3000/user/signin/microsoft'
              : 'http://10.0.2.2:3000/user/signin/microsoft',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return myUser.User.fromJson(data);
      } else {
        print('Server error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Microsoft sign-in error: $e');
      return null;
    }
  }

  Future<myUser.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return null;

      final email = firebaseUser.email;

      final response = await http.post(
        Uri.parse(
          kIsWeb
              ? 'http://localhost:3000/user/signin/google'
              : 'http://10.0.2.2:3000/user/signin/google',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return myUser.User.fromJson(data);
      } else {
        print('Server error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  /*Future<User?> signInWithGoogle() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      print('Google Sign-In is not supported on this platform');
      return null;
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }*/

  Future<void> signOutIfGoogle() async {
    // Only try Google sign-out on mobile and if initialized
    if (!kIsWeb && _googleSignIn != null) {
      try {
        await _googleSignIn!.signOut();
      } catch (e) {
        print('Google sign-out failed: $e');
      }
    }

    // Always sign out from Firebase
    await _auth.signOut();
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      //add collection for signed in user if not existed
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
      //print('Firebase: Signed in!');
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    //print('Firebase: Signed out!');
  }
}
