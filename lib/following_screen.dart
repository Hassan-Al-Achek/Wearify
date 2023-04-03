import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  final String userID;
  const FollowingScreen({super.key, required this.userID});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  ImageProvider<Object>? _getAvatarImage(Map<String, dynamic> userData) {
    if (userData['avatar_url'] != null && userData['avatar_url'] is String) {
      return CachedNetworkImageProvider(userData['avatar_url'] as String);
    } else {
      return null;
    }
  }

  Widget buildSkeleton(int itemCount) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference clientsCollection =
        FirebaseFirestore.instance.collection('clients');

    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: clientsCollection.doc(widget.userID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildSkeleton(5);
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> followingUserIDs =
              userData['following']['userIDs'] ?? [];

          return ListView.builder(
            itemCount: followingUserIDs.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: clientsCollection.doc(followingUserIDs[index]).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> followingSnapshot) {
                  if (followingSnapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (followingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return buildSkeleton(1);
                  }

                  Map<String, dynamic> followingData =
                      followingSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _getAvatarImage(followingData),
                      child: _getAvatarImage(followingData) == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text('@${followingData['username']}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
