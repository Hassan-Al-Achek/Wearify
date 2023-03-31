import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wearify/chat_screen.dart';
import 'package:async/async.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  Future<DocumentSnapshot> fetchUser(String userId) async {
    var users = await FirebaseFirestore.instance
        .collection('clients')
        .doc(userId)
        .get();
    if (kDebugMode) {
      print('I AM HERE');
      print(users);
    }
    return users;
  }

  Stream<List<String>> fetchChatUsers() async* {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final chatsSnapshot = FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots();

    await for (var snapshot in chatsSnapshot) {
      Set<String> userIds = {};
      for (var message in snapshot.docs) {
        String otherUserId = message['receiverId'];
        userIds.add(otherUserId);
      }
      yield userIds.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<List<String>>(
        stream: fetchChatUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          List<String> chatUserIds = snapshot.data!;

          return ListView.builder(
            itemCount: chatUserIds.length,
            itemBuilder: (BuildContext context, int index) {
              String userId = chatUserIds[index];
              return FutureBuilder<DocumentSnapshot>(
                future: fetchUser(userId),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  DocumentSnapshot user = snapshot.data!;
                  return ListTile(
                    title: Text(user['first_name'] + ' ' + user['last_name']),
                    subtitle: Text(user['username']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: user.id,
                          ),
                        ),
                      );
                    },
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
