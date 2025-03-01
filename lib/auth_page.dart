import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skin_guardian/login_page.dart';
import 'package:skin_guardian/home_page.dart';
import 'package:skin_guardian/admin_panel.dart';
import 'package:skin_guardian/firebase_options.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _isLoading = false; // Stop loading

        if (user != null) {
          // Check if the logged-in user is an admin
          if (user.email == "admin@example.com") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanel()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const LoginPage(),
      ),
    );
  }
}
