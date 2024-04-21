import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../index.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  Future logOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthGate(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const Text('ToDo: Profile Page'),
      ElevatedButton(onPressed: () => logOut(), child: const Text('logout'))
    ]));
  }
}
