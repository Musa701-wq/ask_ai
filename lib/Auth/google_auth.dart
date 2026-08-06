import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Future<UserCredential?> signInWithGoogle() async {
//   try {
//     // Start Google Sign-In flow
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) {
//       debugPrint("❌ Sign-in canceled by user");
//       return null;
//     }
//
//     // Get authentication details
//     final GoogleSignInAuthentication googleAuth =
//     await googleUser.authentication;
//
//     // Create a new credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//
//     // Sign in with Firebase
//     final userCredential = await FirebaseAuth.instance.signInWithCredential(
//       credential,
//     );
//
//     // Save user data to Firestore
//     if (userCredential.user != null) {
//       await _saveUserToFirestore(userCredential.user!);
//     }
//
//     debugPrint("✅ Signed in as: ${userCredential.user?.displayName}");
//     return userCredential;
//   } catch (e) {
//     debugPrint("❌ Error signing in with Google: $e");
//     return null;
//   }
// }
//
// Future<void> _saveUserToFirestore(User user) async {
//   try {
//     String? base64Image;
//
//     // Download profile picture and convert to base64 if available
//     if (user.photoURL != null && user.photoURL!.isNotEmpty) {
//       try {
//         final response = await http.get(Uri.parse(user.photoURL!));
//         if (response.statusCode == 200) {
//           base64Image = base64Encode(response.bodyBytes);
//         }
//       } catch (e) {
//         debugPrint("Error downloading profile picture: $e");
//       }
//     }
//
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'name': user.displayName ?? 'User',
//       'email': user.email ?? '',
//       'profilePicture': base64Image ?? '',
//       'provider': 'google',
//       'createdAt': FieldValue.serverTimestamp(),
//       'lastLogin': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//     debugPrint("✅ User data saved to Firestore");
//   } catch (e) {
//     debugPrint("❌ Error saving user to Firestore: $e");
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Configure Google Sign In with client ID
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '184992833888-imt41q5ddv8jifdelhp0rccdi71o7nhh.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
      ],
    );

    // Check if already signed in
    GoogleSignInAccount? currentUser = googleSignIn.currentUser;

    // If no current user, try to sign in silently first
    if (currentUser == null) {
      currentUser = await googleSignIn.signInSilently();
    }

    // If still no user, show the sign-in UI
    if (currentUser == null) {
      currentUser = await googleSignIn.signIn();
    }

    if (currentUser == null) {
      debugPrint("❌ Sign-in canceled by user");
      return null;
    }

    debugPrint("✅ Google user selected: ${currentUser.email}");

    // Get authentication details with error handling
    final GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await currentUser.authentication;
    } catch (e) {
      debugPrint("❌ Error getting authentication: $e");
      await googleSignIn.disconnect();
      return null;
    }

    // Check if tokens are valid
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      debugPrint("❌ Missing authentication tokens");
      await googleSignIn.disconnect();
      return null;
    }

    debugPrint("✅ Got authentication tokens");

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    // Save user data to Firestore
    if (userCredential.user != null) {
      await _saveUserToFirestore(userCredential.user!);
    }

    debugPrint("✅ Signed in as: ${userCredential.user?.displayName}");
    return userCredential;

  } on FirebaseAuthException catch (e) {
    debugPrint("❌ Firebase Auth Error: ${e.code} - ${e.message}");
    await GoogleSignIn().disconnect();
    return null;
  } catch (e) {
    debugPrint("❌ Error signing in with Google: $e");
    await GoogleSignIn().disconnect();
    return null;
  }
}

Future<void> _saveUserToFirestore(User user) async {
  try {
    String? base64Image;

    // Download profile picture and convert to base64 if available
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(user.photoURL!));
        if (response.statusCode == 200) {
          base64Image = base64Encode(response.bodyBytes);
        }
      } catch (e) {
        debugPrint("Error downloading profile picture: $e");
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': user.displayName ?? 'User',
      'email': user.email ?? '',
      'profilePicture': base64Image ?? '',
      'provider': 'google',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint("✅ User data saved to Firestore");
  } catch (e) {
    debugPrint("❌ Error saving user to Firestore: $e");
  }
}