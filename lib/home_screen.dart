import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'index.dart';

class ClassFlowHome extends StatefulWidget {
  const ClassFlowHome({super.key});

  @override
  State<ClassFlowHome> createState() => _ClassFlowHomeState();
}

class _ClassFlowHomeState extends State<ClassFlowHome> {
  Future logOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthGate(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: 
        Column(children: [
          const Text('ToDo: Homescreen'),
          ElevatedButton(onPressed: () => logOut, child: const Text('logout'))
      ])),
    );
  }
}
