import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagesStep extends StatefulWidget {
  const UploadImagesStep({Key? key}) : super(key: key);

  @override
  State<UploadImagesStep> createState() => UploadImagesStepState();
}

abstract class UploadImagesStepData {
  List<XFile> get images;
}

class UploadImagesStepState extends State<UploadImagesStep>
    implements UploadImagesStepData {
  List<XFile> _images = [];

  @override
  List<XFile> get images => _images;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.length <= 4) {
      setState(() {
        _images = pickedFiles;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 4 images')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: 'Select images to upload',
          child: TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Select Images'),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _images
              .asMap()
              .map(
                (index, image) => MapEntry(
                  index,
                  Semantics(
                    label: 'Image ${index + 1}',
                    child: Image.file(
                      File(image.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ],
    );
  }
}
