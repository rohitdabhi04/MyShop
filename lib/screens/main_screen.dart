import 'package:flutter/material.dart';
import '../theme_notifier.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'account_page.dart';
import 'menu_page.dart';

class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final String userName;
  final String userEmail;

  const MainScreen({
    super.key,
    required this.themeNotifier,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(userName: widget.userName),
      const CartPage(),
      AccountPage(
        themeNotifier: widget.themeNotifier,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      MenuPage(themeNotifier: widget.themeNotifier),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }
}
