import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            if (isSigningUp) //show First Name and Last Name fields if signing up
              Column(
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: dobController,
                    decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
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
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isSigningUp)
                  ElevatedButton(
                    onPressed: () {
                      widget.onSignIn(
                        emailController.text,
                        passwordController.text,
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSigningUp = !isSigningUp;
                    });
                  },
                  child: Text(isSigningUp ? 'Cancel' : 'Register'),
                ),
                if (isSigningUp) // Show Register button only when signing up
                  ElevatedButton(
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
                    child: const Text('Confirm'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
