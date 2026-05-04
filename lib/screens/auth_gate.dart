import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'main_screen.dart';
import '../theme_notifier.dart';

class AuthGate extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const AuthGate({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return MainScreen(
            themeNotifier: themeNotifier,
            userName: user.displayName ?? "User",
            userEmail: user.email ?? "",

          );
        }

        return LoginPage(themeNotifier: themeNotifier);
      },
    );
  }
}