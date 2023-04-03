import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowersScreen extends StatefulWidget {
  final String userID;
  const FollowersScreen({super.key, required this.userID});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
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
      appBar: AppBar(title: const Text('Followers')),
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
          List<dynamic> followerUserIDs =
              userData['followers']['userIDs'] ?? [];

          return ListView.builder(
            itemCount: followerUserIDs.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: clientsCollection.doc(followerUserIDs[index]).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> followerSnapshot) {
                  if (followerSnapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (followerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return buildSkeleton(1);
                  }

                  Map<String, dynamic> followerData =
                      followerSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _getAvatarImage(followerData),
                      child: _getAvatarImage(followerData) == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text('@${followerData['username']}'),
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
