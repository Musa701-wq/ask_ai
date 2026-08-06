// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//
// class AppleAuth {
//   static Future<User?> signInWithApple() async {
//     try {
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: [AppleIDAuthorizationScopes.email],
//       );
//
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: credential.identityToken,
//         accessToken: credential.authorizationCode,
//       );
//
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithCredential(oauthCredential);
//       return userCredential.user;
//     } catch (e) {
//       print("Apple Sign-In error: $e");
//       return null;
//     }
//   }
//
//   // Apple Sign Out - Note: Apple doesn't have a specific sign out like Google
//   // We use Firebase sign out which covers both Google and Apple
//   static Future<void> signOut() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       debugPrint("✅ Apple user signed out from Firebase");
//     } catch (e) {
//       debugPrint("❌ Error signing out Apple user: $e");
//       rethrow;
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

//
// class AppleAuth {
//   static Future<User?> signInWithApple() async {
//     try {
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );
//
//       final oauthCredential = OAuthProvider("apple.com").credential(
//         idToken: credential.identityToken,
//         accessToken: credential.authorizationCode,
//       );
//
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithCredential(oauthCredential);
//
//       // Save user data to Firestore
//       if (userCredential.user != null) {
//         await _saveUserToFirestore(
//           userCredential.user!,
//           credential.givenName,
//           credential.familyName,
//         );
//       }
//
//       return userCredential.user;
//     } catch (e) {
//       print("Apple Sign-In error: $e");
//       return null;
//     }
//   }
//
//   static Future<void> _saveUserToFirestore(
//       User user,
//       String? givenName,
//       String? familyName,
//       ) async {
//     try {
//       // Construct display name from Apple's givenName and familyName
//       String displayName = user.displayName ?? '';
//       if (displayName.isEmpty && givenName != null) {
//         displayName = familyName != null
//             ? '$givenName $familyName'
//             : givenName;
//       }
//
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'name': displayName.isNotEmpty ? displayName : 'Apple User',
//         'email': user.email ?? '',
//         'profilePicture': user.photoURL ?? '',
//         'provider': 'apple',
//         'createdAt': FieldValue.serverTimestamp(),
//         'lastLogin': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//       debugPrint("✅ User data saved to Firestore");
//     } catch (e) {
//       debugPrint("❌ Error saving user to Firestore: $e");
//     }
//   }
//
//   // Apple Sign Out - Note: Apple doesn't have a specific sign out like Google
//   // We use Firebase sign out which covers both Google and Apple
//   static Future<void> signOut() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       debugPrint("✅ Apple user signed out from Firebase");
//     } catch (e) {
//       debugPrint("❌ Error signing out Apple user: $e");
//       rethrow;
//     }
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class AppleAuth {
  static Future<User?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      // Save user data to Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(
          userCredential.user!,
          credential.givenName,
          credential.familyName,
        );
      }

      return userCredential.user;
    } catch (e) {
      print("Apple Sign-In error: $e");
      return null;
    }
  }

  static Future<void> _saveUserToFirestore(
      User user,
      String? givenName,
      String? familyName,
      ) async {
    try {
      // Construct display name from Apple's givenName and familyName
      String displayName = user.displayName ?? '';
      if (displayName.isEmpty && givenName != null) {
        displayName = familyName != null
            ? '$givenName $familyName'
            : givenName;
      }

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
        'name': displayName.isNotEmpty ? displayName : 'Apple User',
        'email': user.email ?? '',
        'profilePicture': base64Image ?? '',
        'provider': 'apple',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ User data saved to Firestore");
    } catch (e) {
      debugPrint("❌ Error saving user to Firestore: $e");
    }
  }

  // Apple Sign Out
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint("✅ Apple user signed out from Firebase");
    } catch (e) {
      debugPrint("❌ Error signing out Apple user: $e");
      rethrow;
    }
  }
}