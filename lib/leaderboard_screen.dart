import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Fetch top 100 users based on XP
  Future<QuerySnapshot> _fetchTopUsers() {
    final usersRef = FirebaseFirestore.instance.collection('clients');
    return usersRef.orderBy('xp', descending: true).limit(100).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Top Donators'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchTopUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final topUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: topUsers.length,
            itemBuilder: (context, index) {
              final user = topUsers[index].data() as Map<String, dynamic>;
              final username = user['username'];
              final avatarUrl = user['avatar_url'];
              final xp = user['xp'];

              // Display top 3 users differently
              if (index < 3) {
                return _buildTopThreeUser(index, username, avatarUrl, xp);
              } else {
                return _buildUserRow(username, avatarUrl, xp);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTopThreeUser(
      int index, String username, String avatarUrl, int xp) {
    // Customize the appearance of the top 3 users
    return Container(
        // Your custom widget for the top 3 users
        );
  }

  Widget _buildUserRow(String username, String avatarUrl, int xp) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(username),
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
