import 'package:clothesapp/select_post_type_step.dart';
import 'package:clothesapp/upload_image_step.dart';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: () {
        if (_index <= 0) {
          setState(() {
            _index += 1;
          });
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: const <Step>[
        Step(
          title: Text('Upload Your Clothes Images'),
          content: UploadImagesStep(),
        ),
        Step(
          title: Text('Choose Post Type'),
          content: SelectPostTypeStep(),
        ),
      ],
    );
  }
}
