import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main_screen.dart';
import 'signup_page.dart';
import 'phone_login_page.dart';
import '../theme_notifier.dart';

class LoginPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const LoginPage({super.key, required this.themeNotifier});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  /// EMAIL LOGIN
  Future<void> login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            themeNotifier: widget.themeNotifier,
            userName: user?.displayName ?? "User",
            userEmail: user?.email ?? "",
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  /// GOOGLE LOGIN (FIXED ACCOUNT PICKER)
  Future<void> signInWithGoogle() async {
    print("BUTTON CLICKED");

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      /// 🔥 FORCE ACCOUNT PICKER
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) {
        print("User cancelled");
        return;
      }

      print("Google account selected");

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;

      print("Firebase login success");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            themeNotifier: widget.themeNotifier,
            userName: user?.displayName ?? "User",
            userEmail: user?.email ?? "",
          ),
        ),
      );

    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade700,
              Colors.teal.shade400,
            ],
          ),
        ),

        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(24),

            /// ✅ FIXED (theme support)
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),

            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ✅ FIXED TEXT COLOR AUTO
                    Text(
                      "Welcome Back",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// EMAIL
                    TextFormField(
                      controller: emailController,
                      decoration: _input(context, "Email"),
                      validator: (v) =>
                      v == null || v.isEmpty ? "Email required" : null,
                    ),

                    const SizedBox(height: 15),

                    /// PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: _input(context, "Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => hidePassword = !hidePassword);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// OR
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// GOOGLE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// PHONE LOGIN
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhoneLoginPage(
                                themeNotifier: widget.themeNotifier,
                              ),
                            ),
                          );
                        },
                        child: const Text("Login with Mobile"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// SIGNUP
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignupPage(
                                themeNotifier: widget.themeNotifier,
                              ),
                            ),
                          );
                        },
                        child: const Text("Create Account"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ FIXED INPUT (THEME SUPPORT)
  InputDecoration _input(BuildContext context, String hint) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}