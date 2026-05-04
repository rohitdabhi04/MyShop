import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme_notifier.dart';
import 'account_page.dart';

class MenuPage extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const MenuPage({super.key, required this.themeNotifier});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  String appVersion = "";

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version ${info.version} (${info.buildNumber})";
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
      ),

      body: ListView(
        children: [

          /// PROFILE
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountPage(
                    themeNotifier: widget.themeNotifier,
                    userName: user?.displayName ??
                        user?.email?.split("@")[0] ??
                        "User",
                    userEmail: user?.email ?? "",
                  ),
                ),
              );
            },
          ),

          const Divider(),

          /// DARK MODE
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Theme"),
            value: widget.themeNotifier.value == ThemeMode.dark,
            onChanged: (value) {
              widget.themeNotifier.toggleTheme(value);
            },
          ),

          const SizedBox(height: 20),

          /// 🔥 APP VERSION (BOTTOM)
          Center(
            child: Text(
              appVersion,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}