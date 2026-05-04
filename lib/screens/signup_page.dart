import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main_screen.dart';
import '../theme_notifier.dart';
import 'phone_login_page.dart';

class SignupPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const SignupPage({super.key, required this.themeNotifier});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  /// EMAIL SIGNUP
  Future<void> signup() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {

      UserCredential credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await credential.user!
          .updateDisplayName(nameController.text.trim());

      final user = FirebaseAuth.instance.currentUser;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            themeNotifier: widget.themeNotifier,
            userName: user?.displayName ?? "User",
            userEmail: user?.email ?? "",
          ),
        ),
            (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  /// 🔥 GOOGLE SIGNUP (ACCOUNT PICKER FIXED)
  Future<void> signInWithGoogle() async {
    print("GOOGLE CLICKED");

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      /// 🔥 FORCE ACCOUNT PICKER
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            themeNotifier: widget.themeNotifier,
            userName: user?.displayName ?? "User",
            userEmail: user?.email ?? "",
          ),
        ),
            (route) => false,
      );

    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Signup Failed: $e")),
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
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.75,

            /// ✅ FIXED (THEME SUPPORT)
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

                    /// ✅ FIXED TEXT
                    Text(
                      "Create Account",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// NAME
                    TextFormField(
                      controller: nameController,
                      decoration: _input(context, "Full Name"),
                      validator: (v) =>
                      v == null || v.length < 3
                          ? "Enter valid name"
                          : null,
                    ),

                    const SizedBox(height: 15),

                    /// EMAIL
                    TextFormField(
                      controller: emailController,
                      decoration: _input(context, "Email"),
                      validator: (v) =>
                      v == null || v.isEmpty
                          ? "Email required"
                          : null,
                    ),

                    const SizedBox(height: 15),

                    /// PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _input(context, "Password"),
                      validator: (v) =>
                      v != null && v.length >= 6
                          ? null
                          : "Min 6 characters",
                    ),

                    const SizedBox(height: 25),

                    /// EMAIL SIGNUP
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Sign up",
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

                    /// GOOGLE SIGNUP
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

                    /// PHONE SIGNUP
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
                        child: const Text("Register with Mobile"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// BACK TO LOGIN
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Already have an account? Login"),
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

  /// ✅ FIXED INPUT FIELD
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