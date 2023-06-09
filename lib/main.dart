import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wearify/auth_gate.dart';
import 'firebase_options.dart';
import 'package:wearify/app_theme.dart';
import 'package:wearify/splash_screen.dart';

Future<void> main(List<String> args) async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      // ! Don't forget to remove showSemanticsDebugger or change it to false
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          titleMedium: TextStyle(color: subduedTextColor),
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
      ),
      home: const SplashScreen(),
      routes: {
        '/auth_gate': (context) => const AuthGate(),
      },
    ),
  );
}
