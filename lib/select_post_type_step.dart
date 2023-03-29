import 'package:flutter/material.dart';

enum PostType { sell, rent, donate }

class SelectPostTypeStep extends StatefulWidget {
  const SelectPostTypeStep({Key? key}) : super(key: key);

  @override
  State<SelectPostTypeStep> createState() => _SelectPostTypeStepState();
}

class _SelectPostTypeStepState extends State<SelectPostTypeStep> {
  PostType _selectedPostType = PostType.sell;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PostType>(
      value: _selectedPostType,
      onChanged: (PostType? newValue) {
        setState(() {
          _selectedPostType = newValue!;
        });
      },
      items: const <DropdownMenuItem<PostType>>[
        DropdownMenuItem<PostType>(
          value: PostType.sell,
          child: Text('Sell'),
        ),
        DropdownMenuItem<PostType>(
          value: PostType.rent,
          child: Text('Rent'),
        ),
        DropdownMenuItem<PostType>(
          value: PostType.donate,
          child: Text('Donate'),
        ),
      ],
    );
  }
}
