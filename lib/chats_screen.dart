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

    final sentMessagesSnapshot = FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .snapshots();
    final receivedMessagesSnapshot = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots();

    await for (var sentSnapshot in sentMessagesSnapshot) {
      await for (var receivedSnapshot in receivedMessagesSnapshot) {
        Set<String> userIds = {};
        for (var message in sentSnapshot.docs) {
          String otherUserId = message['receiverId'];
          userIds.add(otherUserId);
        }
        for (var message in receivedSnapshot.docs) {
          String otherUserId = message['senderId'];
          userIds.add(otherUserId);
        }
        yield userIds.toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', semanticsLabel: 'Chats'),
      ),
      body: StreamBuilder<List<String>>(
        stream: fetchChatUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // * To-Do: Replace it with skeleton effect
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
                  return Semantics(
                    label:
                        'Open chat with ${user['first_name']} ${user['last_name']}',
                    child: ListTile(
                      title: Text(
                        user['first_name'] + ' ' + user['last_name'],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      subtitle: Text(
                        user['username'],
                      ),
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
                    ),
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
