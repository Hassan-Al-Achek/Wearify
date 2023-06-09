import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId;
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _firestore.collection('messages').add({
        'senderId': _currentUserId,
        'receiverId': widget.receiverId,
        'text': _messageController.text.trim(),
        'timestamp': Timestamp.now(),
        'pair': {_currentUserId, widget.receiverId}.toList().join('-'),
      });
      _messageController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('', semanticsLabel: 'Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    Stream<QuerySnapshot> messageStream() {
      return _firestore
          .collection('messages')
          .where('pair', whereIn: [
            {_currentUserId, widget.receiverId}.toList().join('-'),
            {widget.receiverId, _currentUserId}.toList().join('-'),
          ])
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: messageStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonLoading();
        }

        List<DocumentSnapshot> messages = snapshot.data!.docs;

        return AnimatedList(
          key: _animatedListKey,
          reverse: true,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            DocumentSnapshot message = messages[index];
            bool isSentByCurrentUser = message['senderId'] == _currentUserId;

            return SizeTransition(
              sizeFactor: animation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: isSentByCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isSentByCurrentUser
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Semantics(
                        label:
                            'Message from ${isSentByCurrentUser ? "you" : "receiver"}: ${message['text']}',
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isSentByCurrentUser
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          initialItemCount: messages.length,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Type a message',
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}

class SkeletonMessage extends StatelessWidget {
  final bool isSentByCurrentUser;

  const SkeletonMessage({super.key, required this.isSentByCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isSentByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              width: 150,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: 10, // You can customize the number of placeholders
      itemBuilder: (BuildContext context, int index) {
        return SkeletonMessage(
          isSentByCurrentUser: index % 2 == 0,
        );
      },
    );
  }
}
