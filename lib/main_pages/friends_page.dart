import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../index.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const Text('ToDo: Friend'),
    ]));
  }
}
