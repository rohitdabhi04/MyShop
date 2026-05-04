import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import '../theme_notifier.dart';

class ProfileSetupPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final String phone;

  const ProfileSetupPage({
    super.key,
    required this.themeNotifier,
    required this.phone,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {

  final nameController = TextEditingController();
  bool loading = false;

  void saveProfile() async {

    if (nameController.text.trim().length < 3) return;

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;

    /// SAVE USER DATA
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({
      "name": nameController.text.trim(),
      "phone": widget.phone,
      "createdAt": DateTime.now(),
    });

    /// UPDATE AUTH NAME
    await user.updateDisplayName(nameController.text.trim());

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(
          themeNotifier: widget.themeNotifier,
          userName: nameController.text.trim(),
          userEmail: "",
        ),
      ),
          (route) => false,
    );

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),

        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Complete Profile",
                  style: theme.textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: _input(context, "Enter your name"),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : saveProfile,
                  style: _btn(context),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  ButtonStyle _btn(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}