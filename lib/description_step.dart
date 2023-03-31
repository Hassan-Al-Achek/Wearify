import 'package:flutter/material.dart';

enum Gender { male, female }

enum ClothesType { shoes, tshirt, pants, others }

enum Quality { excellent, good, fair }

class DescriptionStep extends StatefulWidget {
  const DescriptionStep({Key? key}) : super(key: key);

  @override
  State<DescriptionStep> createState() => DescriptionStepState();
}

abstract class DescriptionStepData {
  Gender get selectedGender;
  ClothesType get selectedClothesType;
  String? get customClothesType;
  String? get selectedSize;
  String? get customSize;
  Quality get selectedQuality;
  String get description;
}

class DescriptionStepState extends State<DescriptionStep>
    implements DescriptionStepData {
  Gender _selectedGender = Gender.male;
  ClothesType _selectedClothesType = ClothesType.shoes;
  String? _customClothesType;
  String? _selectedSize;
  String? _customSize;
  Quality _selectedQuality = Quality.excellent;
  TextEditingController _descriptionController = TextEditingController();

  @override
  Gender get selectedGender => _selectedGender;

  @override
  ClothesType get selectedClothesType => _selectedClothesType;

  @override
  String? get customClothesType => _customClothesType;

  @override
  String? get selectedSize => _selectedSize;

  @override
  String? get customSize => _customSize;

  @override
  Quality get selectedQuality => _selectedQuality;

  @override
  @override
  String get description => _descriptionController.text;

  List<String> getSizes(ClothesType clothesType) {
    List<String> sizes = [];

    if (clothesType == ClothesType.shoes) {
      for (int i = 10; i <= 45; i++) {
        sizes.add(i.toString());
      }
    } else {
      sizes = ['S', 'M', 'L', 'XL', 'XXL'];
    }

    sizes.add('Others');
    return sizes;
  }

  @override
  Widget build(BuildContext context) {
    List<String> sizes = getSizes(_selectedClothesType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender dropdown
        DropdownButton<Gender>(
          value: _selectedGender,
          onChanged: (Gender? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          items: const <DropdownMenuItem<Gender>>[
            DropdownMenuItem<Gender>(
              value: Gender.male,
              child: Text('Male'),
            ),
            DropdownMenuItem<Gender>(
              value: Gender.female,
              child: Text('Female'),
            ),
          ],
        ),

        // Clothes type dropdown
        DropdownButton<ClothesType>(
          value: _selectedClothesType,
          onChanged: (ClothesType? newValue) {
            setState(() {
              _selectedClothesType = newValue!;
              _selectedSize = null; // Reset the selected size
            });
          },
          items: ClothesType.values
              .map<DropdownMenuItem<ClothesType>>((clothesType) {
            return DropdownMenuItem<ClothesType>(
              value: clothesType,
              child: Text(clothesType.toString().split('.').last),
            );
          }).toList(),
        ),

        // Custom clothes type input
        if (_selectedClothesType == ClothesType.others)
          TextField(
            onChanged: (String value) {
              setState(() {
                _customClothesType = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Custom Clothes Type',
              hintText: 'Enter a custom clothes type',
            ),
          ),

        // Size dropdown
        DropdownButton<String>(
          value: _selectedSize,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSize = newValue;
            });
          },
          items: sizes.map<DropdownMenuItem<String>>((size) {
            return DropdownMenuItem<String>(
              value: size,
              child: Text(size),
            );
          }).toList(),
        ),

        // In case the size does not exist the user can enter a one
        if (_selectedSize == 'Others')
          TextField(
            onChanged: (String value) {
              setState(() {
                _customSize = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Custom Size',
              hintText: 'Enter a custom size',
            ),
          ),

        // Quality radio buttons
        // Quality radio buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: Quality.values.map<Widget>((quality) {
            return ListTile(
              title: Text(quality.toString().split('.').last),
              leading: Radio<Quality>(
                value: quality,
                groupValue: _selectedQuality,
                onChanged: (Quality? newValue) {
                  setState(() {
                    _selectedQuality = newValue!;
                  });
                },
                activeColor: Colors.blue,
              ),
            );
          }).toList(),
        ),

        // Description text field
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter a short description for your post',
          ),
        ),
      ],
    );
  }
}
