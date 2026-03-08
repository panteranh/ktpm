import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/auth_page.dart';
import 'package:mangaapp1/main.dart'; // We need a reference to MainScreen

class AuthGate extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const AuthGate({super.key, required this.isDark, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is not logged in
          if (!snapshot.hasData) {
            return const AuthPage();
          }

          // User is logged in
          return MainScreen(isDark: isDark, toggleTheme: toggleTheme);
        },
      ),
    );
  }
}
