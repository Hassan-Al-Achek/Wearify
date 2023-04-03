import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wearify/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wearify/post_item.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool _isFollowing = false;

  ImageProvider<Object>? _getAvatarImage(Map<String, dynamic> userData) {
    if (userData['avatar_url'] != null && userData['avatar_url'] is String) {
      return CachedNetworkImageProvider(userData['avatar_url'] as String);
    } else {
      return null;
    }
  }

  Map<String, int> _getFollowersFollowingCount(Map<String, dynamic> userData) {
    int followersCount = userData['followers']?['userIDs']?.length ?? 0;
    int followingCount = userData['following']?['userIDs']?.length ?? 0;

    return {'followers': followersCount, 'following': followingCount};
  }

  // * Check if the currentUser is following the targetUser (The user i am visiting his/her profile)
  bool _isFollowingUser(Map<String, dynamic> currentUserData) {
    List<dynamic> currentUserFollowingUserIDs =
        currentUserData['following']['userIDs'] ?? [];
    return currentUserFollowingUserIDs.contains(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference clientsCollection =
        FirebaseFirestore.instance.collection('clients');
    CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('clothes');

    Future<void> followUser() async {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference currentUserDoc =
          FirebaseFirestore.instance.collection('clients').doc(currentUserId);
      DocumentReference userToFollowDoc =
          FirebaseFirestore.instance.collection('clients').doc(widget.userId);

      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          DocumentSnapshot currentUserSnapshot =
              await transaction.get(currentUserDoc);
          DocumentSnapshot userToFollowSnapshot =
              await transaction.get(userToFollowDoc);

          List<dynamic> currentUserFollowingUserIDs =
              currentUserSnapshot['following']['userIDs'] ?? [];
          List<dynamic> currentUserFollowingUsernames =
              currentUserSnapshot['following']['userNames'] ?? [];

          List<dynamic> targetUserFollowerUserIDs =
              userToFollowSnapshot['followers']['userIDs'] ?? [];
          List<dynamic> targetUserFollowerUsernames =
              userToFollowSnapshot['followers']['userNames'] ?? [];

          if (_isFollowing) {
            currentUserFollowingUserIDs.remove(widget.userId);
            currentUserFollowingUsernames
                .remove(userToFollowSnapshot['username']);

            targetUserFollowerUserIDs.remove(currentUserId);
            targetUserFollowerUsernames.remove(currentUserSnapshot['username']);
          } else {
            currentUserFollowingUserIDs.add(widget.userId);
            currentUserFollowingUsernames.add(userToFollowSnapshot['username']);

            targetUserFollowerUserIDs.add(currentUserId);
            targetUserFollowerUsernames.add(currentUserSnapshot['username']);
          }

          transaction.update(
            currentUserDoc,
            {
              'following': {
                'userIDs': currentUserFollowingUserIDs,
                'userNames': currentUserFollowingUsernames,
              }
            },
          );

          transaction.update(
            userToFollowDoc,
            {
              'followers': {
                'userIDs': targetUserFollowerUserIDs,
                'userNames': targetUserFollowerUsernames,
              }
            },
          );
        },
      );

      setState(() {
        _isFollowing = !_isFollowing;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: clientsCollection.doc(widget.userId).snapshots(),
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
                      Column(
                        children: [
                          Semantics(
                            label: 'Chat with user',
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(receiverId: widget.userId),
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
                          const SizedBox(height: 5),
                          StreamBuilder<DocumentSnapshot>(
                            stream: clientsCollection
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot>
                                    currentUserSnapshot) {
                              if (currentUserSnapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (currentUserSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              Map<String, dynamic> currentUserData =
                                  currentUserSnapshot.data!.data()
                                      as Map<String, dynamic>;
                              _isFollowing = _isFollowingUser(currentUserData);

                              return ElevatedButton(
                                onPressed: () async {
                                  await followUser();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isFollowing ? Colors.orange : null,
                                ),
                                child:
                                    Text(_isFollowing ? 'Following' : 'Follow'),
                              );
                            },
                          ),
                        ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to the followers list screen
                        },
                        child: Semantics(
                          label: 'Followers count',
                          child: Text(
                            'Followers: ${_getFollowersFollowingCount(userData)['followers']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to the following list screen
                        },
                        child: Semantics(
                          label: 'Following count',
                          child: Text(
                            'Following: ${_getFollowersFollowingCount(userData)['following']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
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
                        .where('userId', isEqualTo: widget.userId)
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
