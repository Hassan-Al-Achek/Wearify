import 'package:clothesapp/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _signIn() async {
    if (_signInFormKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        // Navigate to the next screen or show a success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHome()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle the error (e.g., show a Snackbar with the error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign in failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Form(
        key: _signInFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Email Address Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  validator: MultiValidator([
                    RequiredValidator(errorText: '* Required'),
                    EmailValidator(errorText: "Enter a valid email address"),
                  ]),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: '',
                  ),
                ),
              ),

              //Password Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  validator: MultiValidator(
                    [
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(
                        8,
                        errorText: "Password should be atleast 8 characters",
                      ),
                    ],
                  ),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    hintText: '',
                  ),
                  obscureText: _isPasswordVisible,
                ),
              ),

              // Sigin Button
              ElevatedButton(
                onPressed: _signIn, // i will implement the sigin function

                // STYLING, will return to it back
                // style: ButtonStyle(
                //   backgroundColor:
                //       MaterialStateColor.resolveWith((states) => Colors.red),
                // ),

                child: const Text('Log In'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
