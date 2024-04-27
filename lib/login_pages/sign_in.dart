import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignInScreen extends StatefulWidget {
  final Function(String, String) onSignIn;
  final Function(String, String, String, String, String, String) onSignUp;

  const SignInScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String selectedGender = 'Male';

  bool isSigningUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to ClassFlow!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/images/plane.jpg',
                  height: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Sign in or sign up below to get started',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                if (isSigningUp) SignUpOptions(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!isSigningUp)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[100],
                            surfaceTintColor: Colors.deepOrange[100],
                            foregroundColor: Colors.deepOrange[100]),
                        onPressed: () {
                          widget.onSignIn(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange[100],
                          surfaceTintColor: Colors.deepOrange[100],
                          foregroundColor: Colors.deepOrange[100],
                          shadowColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          isSigningUp = !isSigningUp;
                        });
                      },
                      child: Text(
                        isSigningUp ? 'Cancel' : 'Register',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (isSigningUp) // Show Register button only when signing up
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[100],
                            surfaceTintColor: Colors.deepOrange[100],
                            foregroundColor: Colors.deepOrange[100]),
                        onPressed: () {
                          // Call onSignUp callback with email, password, first name, and last name
                          widget.onSignUp(
                              emailController.text,
                              passwordController.text,
                              firstNameController.text,
                              lastNameController.text,
                              dobController.text,
                              selectedGender);
                        },
                        child: const Text('Confirm',
                            style: TextStyle(color: Colors.black)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column SignUpOptions() {
    return Column(
      children: [
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        const SizedBox(
          height: 16.0,
        ),
        TextField(
          controller: dobController,
          decoration: InputDecoration(
              labelText: 'Date of Birth',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              hintText: 'mm/dd/yyyy'),
        ),
        const SizedBox(
          height: 16.0,
        ),
        DropdownButtonFormField<String>(
          value: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value!;
            });
          },
          items: ['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
