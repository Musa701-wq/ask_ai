// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:docusense_ai/providers/auth_state.dart';
// import 'package:docusense_ai/Auth/apple_auth.dart';
// import '../Auth/google_auth.dart';
//
// Future<bool> showSignInDialog(BuildContext context) async {
//   bool signInAttempted = false;
//
//   final result = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false, // Prevent dismissing by tapping outside
//     builder: (BuildContext dialogContext) {
//       return WillPopScope(
//         onWillPop: () async => false, // Prevent back button dismiss
//         child: AlertDialog(
//           title: const Text('Sign In'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   if (signInAttempted) return; // Prevent double-tap
//                   signInAttempted = true;
//
//                   try {
//                     final userCredential = await signInWithGoogle();
//
//                     if (userCredential != null && userCredential.user != null) {
//                       // Update AuthState
//                       if (context.mounted) {
//                         final authState = Provider.of<AuthState>(context, listen: false);
//                         authState.signIn(userCredential.user!);
//
//                         if (dialogContext.mounted) {
//                           Navigator.of(dialogContext).pop(true);
//                         }
//                       }
//                     } else {
//                       signInAttempted = false;
//                       if (dialogContext.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Sign-in was cancelled'),
//                             duration: Duration(seconds: 2),
//                           ),
//                         );
//                       }
//                     }
//                   } catch (e) {
//                     signInAttempted = false;
//                     debugPrint("Error in sign-in dialog: $e");
//                     if (dialogContext.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Sign-in failed: $e'),
//                           duration: const Duration(seconds: 2),
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text('Sign in with Google'),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (signInAttempted) return;
//                   signInAttempted = true;
//
//                   try {
//                     final user = await AppleAuth.signInWithApple();
//
//                     if (user != null) {
//                       if (context.mounted) {
//                         final authState = Provider.of<AuthState>(context, listen: false);
//                         authState.signIn(user);
//
//                         if (dialogContext.mounted) {
//                           Navigator.of(dialogContext).pop(true);
//                         }
//                       }
//                     } else {
//                       signInAttempted = false;
//                       if (dialogContext.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Apple sign-in was cancelled'),
//                             duration: Duration(seconds: 2),
//                           ),
//                         );
//                       }
//                     }
//                   } catch (e) {
//                     signInAttempted = false;
//                     debugPrint("Error in Apple sign-in: $e");
//                     if (dialogContext.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Apple sign-in failed: $e'),
//                           duration: const Duration(seconds: 2),
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text('Sign in with Apple'),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   if (dialogContext.mounted) {
//                     Navigator.of(dialogContext).pop(false);
//                   }
//                 },
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
//
//   return result ?? false;
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docusense_ai/providers/auth_state.dart';
import 'package:docusense_ai/Auth/apple_auth.dart';
import '../Auth/google_auth.dart';
import 'dart:ui' as ui;

Future<bool> showSignInDialog(BuildContext context) async {
  bool signInAttempted = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext dialogContext) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8A2BE2), Color(0xFF6A0DAD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFF0F0F0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8A2BE2), Color(0xFF6A0DAD)],
                            ).createShader(bounds);
                          },
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Google Sign In Button
                    _buildSignInButton(
                      context: context,
                      dialogContext: dialogContext,
                      icon: Icons.g_mobiledata,
                      label: 'Sign in with Google',
                      onPressed: () async {
                        if (signInAttempted) return;
                        signInAttempted = true;

                        try {
                          final userCredential = await signInWithGoogle();

                          if (userCredential != null && userCredential.user != null) {
                            if (context.mounted) {
                              final authState = Provider.of<AuthState>(context, listen: false);
                              authState.signIn(userCredential.user!);

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(true);
                              }
                            }
                          } else {
                            signInAttempted = false;
                            if (dialogContext.mounted) {
                             // _showSnackBar(context, 'Sign-in was cancelled');
                            }
                          }
                        } catch (e) {
                          signInAttempted = false;
                          debugPrint("Error in sign-in dialog: $e");
                          if (dialogContext.mounted) {
                           // _showSnackBar(context, 'Sign-in failed: $e');
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Apple Sign In Button
                    _buildSignInButton(
                      context: context,
                      dialogContext: dialogContext,
                      icon: Icons.apple,
                      label: 'Sign in with Apple',
                      onPressed: () async {
                        if (signInAttempted) return;
                        signInAttempted = true;

                        try {
                          final user = await AppleAuth.signInWithApple();

                          if (user != null) {
                            if (context.mounted) {
                              final authState = Provider.of<AuthState>(context, listen: false);
                              authState.signIn(user);

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(true);
                              }
                            }
                          } else {
                            signInAttempted = false;
                            if (dialogContext.mounted) {
                             // _showSnackBar(context, 'Apple sign-in was cancelled');
                            }
                          }
                        } catch (e) {
                          signInAttempted = false;
                          debugPrint("Error in Apple sign-in: $e");
                          if (dialogContext.mounted) {
                           // _showSnackBar(context, 'Apple sign-in failed: $e');
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(false);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}

Widget _buildSignInButton({
  required BuildContext context,
  required BuildContext dialogContext,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF8A2BE2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color(0xFF6A0DAD),
    ),
  );
}