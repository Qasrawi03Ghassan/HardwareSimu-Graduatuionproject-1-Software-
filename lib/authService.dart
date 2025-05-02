import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform; // Only import this if not building for web
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<User?> signInWithGoogle() async {
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
  }

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
