import 'package:clothesapp/description_step.dart';
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
  PostType _selectedPostType = PostType.sell;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepContinue: () {
        if (_index < 3) {
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
        const Step(
          title: Text('Upload Your Clothes Images'),
          content: UploadImagesStep(),
        ),
        Step(
          title: const Text('Choose Post Type'),
          content: SelectPostTypeStep(
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
        ),
        const Step(
          title: Text('Description'),
          content: DescriptionStep(),
        ),
        const Step(
          title: Text('Step-4'),
          content: Text('To do'),
        ),
      ],
    );
  }
}
