import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme_notifier.dart';
import 'login_page.dart';

class AccountPage extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  final String userName;
  final String userEmail;

  const AccountPage({
    super.key,
    required this.themeNotifier,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          /// PROFILE IMAGE
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),

          const SizedBox(height: 12),

          /// NAME
          Center(
            child: Text(
              userName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          /// EMAIL
          Center(
            child: Text(
              userEmail,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),

          const SizedBox(height: 30),

          /// LOGOUT CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                "Log Out",
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FINAL LOGOUT FUNCTION (WORKING)
  Future<void> _logout(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      /// 🔥 Firebase logout
      await FirebaseAuth.instance.signOut();

      /// 🔥 Google logout (NO disconnect)
      await googleSignIn.signOut();

      /// Navigate to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(
            themeNotifier: themeNotifier,
          ),
        ),
            (route) => false,
      );

    } catch (e) {
      print("Logout error: $e");
    }
  }

  /// 🔥 POPUP UI
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {

        final scale = Tween(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        final opacity = Tween(begin: 0.0, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: opacity,
          child: Stack(
            children: [

              /// BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),

              /// POPUP
              ScaleTransition(
                scale: scale,
                child: Center(
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.cardColor,
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const Text(
                            "Are you sure you want to log out?",
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          /// LOGOUT BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                await _logout(context);
                              },
                              child: const Text(
                                "Log Out",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// CANCEL
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}