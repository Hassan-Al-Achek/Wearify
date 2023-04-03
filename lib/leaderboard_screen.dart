import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Fetch top 100 users based on XP
  Future<QuerySnapshot> _fetchTopUsers() {
    final usersRef = FirebaseFirestore.instance.collection('leaderboard');
    return usersRef
        .orderBy('xp', descending: true)
        .limit(100)
        .get()
        .then((querySnapshot) {
      if (kDebugMode) {
        print('Fetched users: ${querySnapshot.docs}');
      }
      return querySnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchTopUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _skeletonLoader(context);
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final topUsers = snapshot.data!.docs;

          return ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Semantics(
                  label: 'Our Top Donors',
                  header: true,
                  child: Text(
                    'Our Top Donors',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topUsers.length,
                itemBuilder: (context, index) {
                  final user = topUsers[index].data() as Map<String, dynamic>;
                  final username = user['username'];
                  if (kDebugMode) {
                    print('User data: $user');
                  }
                  final avatarUrl = user['avatar_url'];
                  final xp = user['xp'];

                  // Display top 3 users differently
                  if (index < 3) {
                    return _buildTopThreeUser(index, username, avatarUrl, xp);
                  } else {
                    return Semantics(
                      label: 'User $username with $xp XP',
                      child: _buildUserRow(username, avatarUrl, xp),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopThreeUser(
      int index, String username, String avatarUrl, int xp) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        'Top ${index + 1}: $username',
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      trailing: _xpWidget(xp),
    );
  }

  Widget _buildUserRow(String username, String avatarUrl, int xp) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        username,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      trailing: _xpWidget(xp),
    );
  }

  Widget _xpWidget(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.blue,
      ),
      child: Text(
        '$xp XP',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

Widget _skeletonLoader(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48.0,
            height: 48.0,
            color: Colors.white,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 14.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
