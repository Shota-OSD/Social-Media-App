import 'package:flutter/material.dart';

// make firestore collection for each topic
// topics will store posts
// posts will store user, post (image or text), and comments
// comments will store 'chats' between different users (see hw4-chat)

class TopicRoom extends StatefulWidget {
  final String topic;
  const TopicRoom({super.key, required this.topic});

  @override
  State<TopicRoom> createState() => _TopicRoomState();
}

class _TopicRoomState extends State<TopicRoom> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}