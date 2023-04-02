import 'package:wearify/chats_screen.dart';
import 'package:wearify/public_profile_sceen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

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

  Widget _buildPost(Map<String, dynamic> data) {
    String? description = data['description'] ?? '';
    List<dynamic>? images = data['images'] ?? [];
    int quality = data['quality'] ?? 0;
    String postType = '';
    IconData priceIcon = Icons.attach_money;
    String price = '';
    int clothesType = data['clothesType'] ?? 0;
    String customClothesType = data['customClothesType'] ?? '';
    String size = data['size'] ?? 'Others';
    String customSize = data['customSize'] ?? '';

    switch (data['postType']) {
      case 0:
        postType = 'For sale';
        price = data['price'] ?? '';
        break;
      case 1:
        postType = 'For rent';
        price = data['price'] ?? '';
        price += '/day';
        break;
      case 2:
        postType = 'Donation';
        price = 'Thank';
        break;
      default:
        postType = 'Unknown';
    }

    String qualityIndicator = '';

    switch (quality) {
      case 0:
        qualityIndicator = 'Excellent';
        break;
      case 1:
        qualityIndicator = 'Good';
        break;
      case 2:
        qualityIndicator = 'Fair';
        break;
      default:
        qualityIndicator = 'Unknown';
    }

    String clothesTypeStr = '';

    if (clothesType == 3) {
      clothesTypeStr = customClothesType;
    } else {
      switch (clothesType) {
        case 0:
          clothesTypeStr = 'Shoes';
          break;
        case 1:
          clothesTypeStr = 'T-shirt';
          break;
        case 2:
          clothesTypeStr = 'Pants';
          break;
        default:
          clothesTypeStr = 'Unknown';
      }
    }

    String sizeStr = '';

    if (size == 'Others') {
      sizeStr = customSize;
    } else {
      sizeStr = size;
    }

    Widget singleSkeletonLoader() {
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
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('clients')
          .doc(data['userId'])
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return singleSkeletonLoader();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['username'] ?? 'Unknown';

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfileScreen(
                          userId: data['userId'],
                        ),
                      ),
                    );
                  },
                  child: Semantics(
                    label: '$username\'s avatar',
                    child: CircleAvatar(
                      backgroundImage: _getAvatarImage(userData),
                    ),
                  ),
                ),
                title: Text(username),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => _openImageGallery(context, images, index),
                      child: CachedNetworkImage(
                        imageUrl: images![index],
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Description: $description!',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quality: $qualityIndicator',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      postType,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Icon(priceIcon),
                        Text(
                          price,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Size: $sizeStr',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Type: $clothesTypeStr',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider<Object>? _getAvatarImage(Map<String, dynamic> userData) {
    if (userData['avatar_url'] != null && userData['avatar_url'] is String) {
      return CachedNetworkImageProvider(userData['avatar_url'] as String);
    } else {
      return null;
    }
  }

  void _openImageGallery(
      BuildContext context, List<dynamic> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
            scrollPhysics: const BouncingScrollPhysics(),
          ),
        ),
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
                .map((doc) => _buildPost(doc.data() as Map<String, dynamic>))
                .toList(),
          );
        },
      ),
      floatingActionButton: Semantics(
        label: 'Open chats screen',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatsScreen(),
              ),
            );
          },
          child: const Icon(Icons.chat),
        ),
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
