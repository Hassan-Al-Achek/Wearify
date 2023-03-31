import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Clothing {
  final int clothesType;
  final String customClothesType;
  final String customSize;
  final String description;
  final int gender;
  final List<String> images;
  final int postType;
  final String price;
  final int quality;
  final String size;
  final String userId;

  Clothing({
    required this.clothesType,
    required this.customClothesType,
    required this.customSize,
    required this.description,
    required this.gender,
    required this.images,
    required this.postType,
    required this.price,
    required this.quality,
    required this.size,
    required this.userId,
  });

  // Add a factory constructor to create a Clothing object from a Map
  factory Clothing.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw const FormatException('Map cannot be null');
    }

    return Clothing(
      clothesType: map['clothesType'] as int,
      customClothesType: map['customClothesType'] as String,
      customSize: map['customSize'] as String,
      description: map['description'] as String,
      gender: map['gender'] as int,
      images: List<String>.from(map['images'] as List),
      postType: map['postType'] as int,
      price: map['price'] as String,
      quality: map['quality'] as int,
      size: map['size'] as String,
      userId: map['userId'] as String,
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  List<Clothing> _clothes = [];

  @override
  void initState() {
    super.initState();
    _fetchClothesData();
  }

  Future<void> _fetchClothesData() async {
    // Fetch the clothes data from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('clothes').get();

    // Convert the fetched documents to a list of Clothing objects
    List<Clothing> fetchedClothes = querySnapshot.docs
        .map((doc) => Clothing.fromMap(doc.data() as Map<String, dynamic>?))
        .toList();

    // Update the _clothes list
    setState(() {
      _clothes = fetchedClothes;
    });
  }

  void _performSearch(String query) {
    // Filter the clothes based on the query
    List<Clothing> filteredClothes = _clothes.where((clothing) {
      return clothing.size.toLowerCase().contains(query.toLowerCase()) ||
          clothing.customSize.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Update the search results with the filtered clothes
    setState(() {
      _searchResults =
          filteredClothes.map((clothing) => clothing.description).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
      ),
      body: _searchResults.isEmpty
          ? const Center(
              child: Text('Search results will be displayed here'),
            )
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_searchResults[index]),
                );
              },
            ),
    );
  }
}
