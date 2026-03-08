import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn;

  AuthService() {
    if (_isGoogleSignInSupported()) {
      _googleSignIn = GoogleSignIn();
    }
  }

  static const String adminEmail = 'admin@coread.com';

  bool isAdmin() {
    final user = _auth.currentUser;
    return user != null && user.email == adminEmail;
  }

  Stream<User?> get user => _auth.authStateChanges();

  bool _isGoogleSignInSupported() {
    if (kIsWeb) return true;
    try {
      return defaultTargetPlatform == TargetPlatform.android ||
             defaultTargetPlatform == TargetPlatform.iOS;
    } catch (e) {
      return false;
    }
  }

  // --- NEW: Helper to save user to Firestore ---
  Future<void> _saveUserToFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Thành viên mới',
      'createdAt': FieldValue.serverTimestamp(),
      'photoURL': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<User?> signInWithGoogle() async {
    if (!_isGoogleSignInSupported() || _googleSignIn == null) {
      throw UnsupportedError('Google Sign-In is not supported on this platform.');
    }
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Save user info on successful Google login
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
      
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user info on successful Registration
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update info on login if needed
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    if (_isGoogleSignInSupported() && _googleSignIn != null) {
      if (await _googleSignIn!.isSignedIn()) {
        await _googleSignIn!.signOut();
      }
    }
    await _auth.signOut();
  }
}
