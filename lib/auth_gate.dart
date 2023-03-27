import 'package:clothesapp/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clothesapp/home_screen.dart';
import 'package:clothesapp/signin_screen.dart';

// * Make sure that the user is logged in
// * Before navigating to the home screen
// * The AuthGate will credirect the user
// * to the signin screen if the user is
// * not logged in or tp the Home screen
// * if the user is logged in

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen();
        }

        return const ProfileScreen();
      },
    );
  }
}
