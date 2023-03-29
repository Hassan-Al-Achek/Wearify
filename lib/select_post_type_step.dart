import 'package:flutter/material.dart';

enum PostType { sell, rent, donate }

class SelectPostTypeStep extends StatefulWidget {
  final Function(PostType) onPostTypeChanged;
  final VoidCallback onIndexChanged;
  const SelectPostTypeStep(
      {Key? key, required this.onPostTypeChanged, required this.onIndexChanged})
      : super(key: key);

  @override
  State<SelectPostTypeStep> createState() => _SelectPostTypeStepState();
}

class _SelectPostTypeStepState extends State<SelectPostTypeStep> {
  PostType _selectedPostType = PostType.sell;
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<PostType>(
          value: _selectedPostType,
          onChanged: (PostType? newValue) {
            setState(() {
              _selectedPostType = newValue!;
            });
            widget.onPostTypeChanged(_selectedPostType);
            if (_selectedPostType == PostType.donate) {
              widget.onIndexChanged();
            }
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
        ),
        const SizedBox(height: 20),
        if (_selectedPostType == PostType.sell ||
            _selectedPostType == PostType.rent)
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _selectedPostType == PostType.sell
                  ? 'Price in dollars'
                  : 'Rent per day in dollars',
              hintText: 'Enter the price',
            ),
          )
        else
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter a description for your post',
            ),
          ),
      ],
    );
  }
}
