import 'package:flutter/material.dart';
import 'package:wearify/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wearify/post_item.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  ImageProvider<Object>? _getAvatarImage(Map<String, dynamic> userData) {
    if (userData['avatar_url'] != null && userData['avatar_url'] is String) {
      return CachedNetworkImageProvider(userData['avatar_url'] as String);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference clientsCollection =
        FirebaseFirestore.instance.collection('clients');
    CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('clothes');

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: clientsCollection.doc(userId).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'User avatar',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: _getAvatarImage(userData),
                          child: _getAvatarImage(userData) == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Semantics(
                        label: 'Chat with user',
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(receiverId: userId),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.chat_rounded,
                            size: 32,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: 'Full Name',
                    child: Text(
                      'Full Name: ${userData['first_name']} ${userData['last_name']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: 'username',
                    child: Text(
                      'Username: @${userData['username']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${userData['first_name']}\'s Posts',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: postsCollection
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> postSnapshot) {
                      if (postSnapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (postSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: postSnapshot.data!.docs
                            .map((doc) => PostItem(
                                data: doc.data() as Map<String, dynamic>))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
