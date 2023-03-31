import 'package:wearify/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:wearify/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login screen
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AuthGate()));
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('${currentUser.uid}.jpg');

        await ref.putFile(imageFile);
        String imageUrl = await ref.getDownloadURL();

        CollectionReference clientsCollection =
            FirebaseFirestore.instance.collection('clients');
        clientsCollection.doc(currentUser.uid).update({'avatar_url': imageUrl});

        CollectionReference leaderBoardCollection =
            FirebaseFirestore.instance.collection('leaderboard');
        leaderBoardCollection
            .doc(currentUser.uid)
            .update({'avatar_url': imageUrl});
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Upload failed')),
        );
      }
    }
  }

  ImageProvider<Object>? _getAvatarImage(Map<String, dynamic> userData) {
    if (userData['avatar_url'] != null && userData['avatar_url'] is String) {
      return CachedNetworkImageProvider(userData['avatar_url'] as String);
    } else {
      return null;
    }
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

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassmorphicContainer(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.5),
                  ],
                ),
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: _getAvatarImage(userData),
                          child: _getAvatarImage(userData) == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style:
                                const TextStyle(color: textColor, fontSize: 18),
                            children: [
                              TextSpan(
                                text: 'Full Name: ${userData['first_name']}',
                              ),
                              TextSpan(
                                text: ' ${userData['last_name']}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Username: @${userData['username']}',
                          style:
                              const TextStyle(color: textColor, fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Email: ${userData['email']}',
                          style:
                              const TextStyle(color: textColor, fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Phone Number: ${userData['phone_number']}',
                          style:
                              const TextStyle(color: textColor, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _signOut,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(primaryColor),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 32.0)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )),
                          ),
                          child: const Text('Log Out',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
