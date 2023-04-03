import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:wearify/chats_screen.dart';
import 'package:wearify/post_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wearify/users_list_screen.dart';
import 'package:wearify/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CollectionReference clothesCollection =
      FirebaseFirestore.instance.collection('clothes');

  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.isScrollingNotifier.value != _isScrolling) {
      setState(() {
        _isScrolling = _scrollController.position.isScrollingNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _openUsersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsersListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: clothesCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _skeletonLoader();
          }
          return ListView(
            children: snapshot.data!.docs
                .map(
                    (doc) => PostItem(data: doc.data() as Map<String, dynamic>))
                .toList(),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        buttonSize: const Size(56.0, 56.0),
        visible: true,
        closeManually: false,
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 8.0,
        children: [
          SpeedDialChild(
            child: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
            backgroundColor: primaryColor,
            label: 'Open chats screen',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatsScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(
              Icons.people,
              color: Colors.white,
            ),
            backgroundColor: primaryColor,
            label: 'Open users list',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: _openUsersList,
          ),
        ],
      ),
    );
  }
}

Widget _skeletonLoader() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (BuildContext context, int index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey),
            title: Container(
              width: double.infinity,
              height: 10.0,
              color: Colors.grey,
            ),
            subtitle: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 10.0,
              color: Colors.grey,
              margin: const EdgeInsets.only(top: 5.0),
            ),
          ),
        ),
      );
    },
  );
}
