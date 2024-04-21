import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../index.dart';


class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPost();
}

class _AddPost extends State<AddPost> {
  

  @override
  Widget build(BuildContext context) {
    return Center(
            child: Column(children: [
          const Text('ToDo: Add_Post Page'),
        ]));
  }
}
