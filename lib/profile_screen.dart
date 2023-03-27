import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Get the current logged in user
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    CollectionReference clientsCollection =
        FirebaseFirestore.instance.collection('clients');

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: clientsCollection.doc(currentUser.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          // Loading screen if data not ready to be displayed
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Username: ${userData['username']}'),
              Text('First Name: ${userData['first_name']}'),
              Text('Last Name: ${userData['last_name']}'),
              Text('Email: ${userData['email']}'),
              Text('Phone Number: ${userData['phone_number']}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text('Log Out'),
              ),
            ],
          );
        },
      ),
    );
  }
}
