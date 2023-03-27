import 'package:clothesapp/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class usernameValidator extends TextFieldValidator {
  usernameValidator(super.errorText);

  @override
  bool isValid(String? value) {
    return hasMatch(r'^[a-zA-Z0-9_][a-zA-Z0-9._]*$', value!);
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _formattedPhoneNumber = '';
  late DateTime? _selectedDateOfBirth = DateTime.now();
  late String _selectedGender = 'Male';
  String initialCountry = 'LB';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedLocation!,
        ),
      );
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 16.0,
          ),
        ),
      );
    });
  }

  Future<void> _signUp() async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);

      // Save the user's additional information in Firestore
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(userCredential.user?.uid)
          .set({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text.toUpperCase(),
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone_number': _formattedPhoneNumber,
        'date_of_birth': _selectedDateOfBirth,
        'gender': _selectedGender,
        // Add the address info (e.g. 'address': _selectedAddress)
      });

      // Navigate to the next screen (e.g. home screen) after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHome()),
      );
    } on FirebaseAuthException catch (e) {
      // Show an error message if there's an exception
      if (mounted) {
        String errorMessage;
        // Show an error message if there's an exception
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email address is already in use.';
        } else {
          errorMessage = 'Failed to sign up. Please try again.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // Show a generic error message if there's any other exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to sign up. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // First Name Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'First Name',
                  ),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "first Name is required"),
                    MaxLengthValidator(
                      30,
                      errorText:
                          'First Name could not be longer than 30 character',
                    ),
                  ]),
                ),
              ),

              // Last Name Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Last Name',
                  ),
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: "Last Name is required"),
                      MaxLengthValidator(
                        30,
                        errorText:
                            'Last Name could not be longer than 30 character',
                      ),
                    ],
                  ),
                ),
              ),

              // Username Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  ),
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: "Username is required"),
                      MinLengthValidator(
                        3,
                        errorText: "Username should be at least 3 characters",
                      ),
                      MaxLengthValidator(
                        30,
                        errorText:
                            "Username could not be longer than 30 characters",
                      ),
                      usernameValidator(
                        'Username should be alphanumeric and can contains only . or _ as special character',
                      ),
                    ],
                  ),
                ),
              ),

              // Email Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: 'Email Address is required'),
                      EmailValidator(
                          errorText: 'Please enter a valid email address'),
                    ],
                  ),
                ),
              ),

              // Password Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: 'Password is required'),
                      MinLengthValidator(8,
                          errorText:
                              'Password must be at least 8 characters long'),
                      PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                          errorText:
                              'Password must have at least one special character'),
                    ],
                  ),
                ),
              ),

              // Confirm Password Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (_passwordController.text != value) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),

              // Phone Number Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InternationalPhoneNumberInput(
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  formatInput: true,
                  inputDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                  ),
                  onInputChanged: (PhoneNumber number) {
                    if (kDebugMode) {
                      print(number.phoneNumber);
                    }
                    _formattedPhoneNumber = number.phoneNumber!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),

              // Date of Birth Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Date of Birth',
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? dateOfBirth = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (dateOfBirth != null) {
                      setState(() {
                        _selectedDateOfBirth = dateOfBirth;
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedDateOfBirth == null) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                      text: _selectedDateOfBirth == null
                          ? ''
                          : DateFormat('yyyy-MM-dd')
                              .format(_selectedDateOfBirth!)),
                ),
              ),

              // Gender Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Gender',
                  ),
                  value: _selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                  items: <String>[
                    'Male',
                    'Female',
                    'Other',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
              ),

              // Address Location Field (Google Maps picker)
              // You will need to implement the Google Maps picker widget and integrate it into this TextFormField
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Address',
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Show the Google Maps picker and get the selected address

                    final LatLng? location = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPicker(
                          initialLocation: _selectedLocation,
                        ),
                      ),
                    );
                    if (location != null) {
                      setState(() {
                        _selectedLocation = location;
                        _markers.clear();
                        _markers.add(
                          Marker(
                            markerId: const MarkerId('selected-location'),
                            position: _selectedLocation!,
                          ),
                        );
                      });
                    }
                  },
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please select your address';
                  //   }
                  //   return null;
                  // },
                  controller: TextEditingController(
                    text: _selectedLocation == null
                        ? ''
                        : '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                  ),
                ),
              ),

              // Sign Up Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signUp();
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Other helper methods for validation, sign up, and address picker
}

class MapPicker extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPicker({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 16.0,
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a location'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation ?? const LatLng(37.7749, -122.4194),
          zoom: 16.0,
        ),
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _selectedLocation!,
                ),
              }
            : {},
      ),
    );
  }
}
