import 'package:clothesapp/description_step.dart';
import 'package:clothesapp/home_screen.dart';
import 'package:clothesapp/select_post_type_step.dart';
import 'package:clothesapp/upload_image_step.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _index = 0;
  PostType _selectedPostType = PostType.sell;

  final GlobalKey<UploadImagesStepState> _uploadImagesStepKey =
      GlobalKey<UploadImagesStepState>();
  final GlobalKey<DescriptionStepState> _descriptionStepKey =
      GlobalKey<DescriptionStepState>();
  final GlobalKey<SelectPostTypeStepState> _selectPostTypeStepKey =
      GlobalKey<SelectPostTypeStepState>();

  Future<void> _savePostToFirebase({
    required List<XFile> images,
    required PostType postType,
    required Gender gender,
    required ClothesType clothesType,
    required String? customClothesType,
    required String? size,
    required String? customSize,
    required Quality quality,
    required String description,
    required String? price,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postId = FirebaseFirestore.instance.collection('clothes').doc().id;

    await FirebaseFirestore.instance.collection('clothes').doc(postId).set({
      'userId': user.uid,
      'images': images.map((image) => image.path).toList(),
      'postType': postType.index,
      'gender': gender.index,
      'clothesType': clothesType.index,
      'customClothesType': customClothesType,
      'size': size,
      'customSize': customSize,
      'quality': quality.index,
      'description': description,
      'price': price,
    });

    if (postType == PostType.donate) {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({'xp': FieldValue.increment(30)});
    }
  }

  bool _validatePost() {
    if (_uploadImagesStepKey.currentState!.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return false;
    }

    if (_descriptionStepKey.currentState!.description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description.')),
      );
      return false;
    }

    if (_selectedPostType != PostType.donate &&
        (_selectPostTypeStepKey.currentState!.price == null ||
            _selectPostTypeStepKey.currentState!.price!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a price.')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepContinue: () {
        if (_index == 3) {
          if (_validatePost()) {
            _savePostToFirebase(
              images: _uploadImagesStepKey.currentState!.images,
              postType: _selectPostTypeStepKey.currentState!.selectedPostType,
              gender: _descriptionStepKey.currentState!.selectedGender,
              clothesType:
                  _descriptionStepKey.currentState!.selectedClothesType,
              customClothesType:
                  _descriptionStepKey.currentState!.customClothesType,
              size: _descriptionStepKey.currentState!.selectedSize,
              customSize: _descriptionStepKey.currentState!.customSize,
              quality: _descriptionStepKey.currentState!.selectedQuality,
              description: _descriptionStepKey.currentState!.description,
              price: _selectPostTypeStepKey.currentState!.price,
            );
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        } else if (_index < 3) {
          setState(() {
            _index += 1;
          });
        }
      },
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: controlsDetails.onStepCancel,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              label: const Text('Previous'),
            ),
            Row(
              children: [
                const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: controlsDetails.onStepContinue,
                  label: const Text(''),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ],
        );
      },
      steps: <Step>[
        Step(
          title: const Text('Upload Your Clothes Images'),
          content: UploadImagesStep(
            key: _uploadImagesStepKey,
          ),
          isActive: _index >= 0,
        ),
        Step(
          title: const Text('Choose Post Type'),
          content: SelectPostTypeStep(
            key: _selectPostTypeStepKey,
            onPostTypeChanged: (PostType newType) {
              setState(() {
                _selectedPostType = newType;
              });
            },
            onIndexChanged: () {
              if (_index < 3) {
                setState(() {
                  _index += 1;
                });
              }
            },
          ),
          isActive: _index >= 1,
        ),
        Step(
          title: const Text('Description'),
          content: DescriptionStep(
            key: _descriptionStepKey,
          ),
          isActive: _index >= 2,
        ),
        Step(
          title: const Text('Post'),
          content: const Text('Ready To Go!'),
          isActive: _index >= 3,
        ),
      ],
    );
  }
}
