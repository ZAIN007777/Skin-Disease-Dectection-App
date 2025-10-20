import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_panel.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's no user, navigate to the LoginPage
          if (!snapshot.hasData) {
            return const LoginPage();
          }

          // If the user is authenticated, check if the user is an admin or not
          User user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userDocSnapshot.hasError) {
                if (kDebugMode) {
                  print("Error fetching user data: ${userDocSnapshot.error}");
                }
                return const LoginPage();
              }

              if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
                // If the user document doesn’t exist, go to HomePage
                return const HomePage();
              }

              final data = userDocSnapshot.data!.data() as Map<String, dynamic>?;

              // Safely read 'isAdmin' field (default to false if missing)
              bool isAdmin = data?['isAdmin'] == true;

              // Navigate to the respective page based on admin status
              return isAdmin ? const AdminPanel() : const HomePage();
            },
          );
        },
      ),
    );
  }
}
