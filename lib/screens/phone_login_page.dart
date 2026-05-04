import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';
import 'profile_setup_page.dart';
import '../theme_notifier.dart';

class PhoneLoginPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const PhoneLoginPage({super.key, required this.themeNotifier});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool loading = false;

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
            height: MediaQuery.of(context).size.height * 0.7,
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
                  otpSent ? "Enter OTP" : "Login with Mobile",
                  style: theme.textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                /// PHONE FIELD
                if (!otpSent)
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _input(context, "+91XXXXXXXXXX"),
                  ),

                /// OTP FIELD
                if (otpSent)
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: _input(context, "Enter OTP"),
                  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                    if (!otpSent) {
                      sendOTP();
                    } else {
                      verifyOTP();
                    }
                  },
                  style: _btn(context),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(otpSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// SEND OTP
  void sendOTP() async {

    setState(() => loading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),

      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
      },

      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          otpSent = true;
        });
      },

      codeAutoRetrievalTimeout: (String verId) {},
    );

    setState(() => loading = false);
  }

  /// VERIFY OTP
  void verifyOTP() async {

    setState(() => loading = true);

    try {
      PhoneAuthCredential credential =
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;

      /// CHECK USER EXISTS
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        /// OLD USER → HOME
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              themeNotifier: widget.themeNotifier,
              userName: doc["name"] ?? user.phoneNumber!,
              userEmail: "",
            ),
          ),
              (route) => false,
        );
      } else {
        /// NEW USER → PROFILE SETUP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(
              themeNotifier: widget.themeNotifier,
              phone: user.phoneNumber!,
            ),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }

    setState(() => loading = false);
  }

  /// INPUT STYLE
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

  /// BUTTON STYLE
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