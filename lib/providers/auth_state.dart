// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AuthState with ChangeNotifier {
//   bool _isUserSignedIn = false;
//   User? _user;
//
//   AuthState() {
//     // Initialize auth state
//     _user = FirebaseAuth.instance.currentUser;
//     _isUserSignedIn = _user != null;
//     // Listen for auth state changes
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       _user = user;
//       _isUserSignedIn = user != null;
//       notifyListeners();
//     });
//   }
//
//   bool get isUserSignedIn => _isUserSignedIn;
//   User? get user => _user;
//
//   void signOut() {
//     _user = null;
//     _isUserSignedIn = false;
//     notifyListeners();
//   }
//
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  User? _user;
  bool _isUserSignedIn = false;

  User? get user => _user;
  bool get isUserSignedIn => _isUserSignedIn;

  // Call this after successful sign-in
  void signIn(User user) {
    _user = user;
    _isUserSignedIn = true;
    notifyListeners();
    debugPrint("✅ AuthState updated: User signed in");
  }

  // Call this on sign-out
  void signOut() {
    _user = null;
    _isUserSignedIn = false;
    notifyListeners();
    debugPrint("✅ AuthState updated: User signed out");
  }

  // Initialize auth state on app start
  void checkAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      signIn(currentUser);
    }
  }
}