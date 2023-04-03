import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

Future<void> registerFakeUser() async {
  Faker faker = Faker();

  String firstName = faker.person.firstName();
  String lastName = faker.person.lastName();
  String username = faker.internet.userName();
  String email = faker.internet.email();
  String password = faker.internet.password();
  String phoneNumber = faker.phoneNumber.us();
  DateTime dateOfBirth = faker.date.dateTime(minYear: 1950, maxYear: 2003);
  String gender = faker.randomGenerator.boolean() ? 'male' : 'female';

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // Create the followers and following dictionary with the userID and username parameters
    Map<String, dynamic> following = {'userIDs': [], 'userNames': []};
    Map<String, dynamic> followers = {'userIDs': [], 'userNames': []};

    await FirebaseFirestore.instance
        .collection('clients')
        .doc(userCredential.user?.uid)
        .set({
      'first_name': firstName,
      'last_name': lastName.toUpperCase(),
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'following': following,
      'followers': followers,
    });

    CollectionReference leaderboardRef =
        FirebaseFirestore.instance.collection('leaderboard');
    await leaderboardRef.doc(userCredential.user?.uid).set({
      'first_name': firstName,
      'last_name': lastName.toUpperCase(),
      'username': username,
      'gender': gender,
      'avatar_url': '',
      'xp': 0,
    });
  } catch (e) {
    if (kDebugMode) {
      print('Error while creating fake user: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // for (int i = 0; i < 30; i++) {
  //   await registerFakeUser();
  //   await Future.delayed(
  //       const Duration(seconds: 1)); // Add a delay between user creation
  // }
  runApp(const MyApp());
}
