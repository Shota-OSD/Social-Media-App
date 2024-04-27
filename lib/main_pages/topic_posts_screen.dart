import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/util/post_service.dart';
import 'post/post_item.dart';

class TopicRoom extends StatefulWidget {
  final String topicID;
  final FirebaseAuth auth;
  const TopicRoom({super.key, required this.topicID, required this.auth});

  @override
  State<TopicRoom> createState() => _TopicRoomState();
}

class _TopicRoomState extends State<TopicRoom> {
  final PostService _chatService = PostService();
  late int? postLikes = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  //background colors based on topic
  late Color? appBarColor;
  late Color? topicColor;
  @override
  void initState() {
    super.initState();
    topicTheme(widget.topicID);
  }

  void topicTheme(topicID) {
    if (widget.topicID.contains('Math')) {
      appBarColor = Colors.deepOrange;
    } else if (widget.topicID.contains('Science')) {
      appBarColor = Colors.lightBlue;
    } else if (widget.topicID.contains('History')) {
      appBarColor = Colors.brown;
    } else if (widget.topicID.contains('English')) {
      appBarColor = Colors.greenAccent;
    } else if (widget.topicID.contains('Art')) {
      appBarColor = Colors.yellowAccent[100];
    } else {
      appBarColor = Colors.deepPurpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.topicID),
        backgroundColor: appBarColor,
      ),
      floatingActionButton: ElevatedButton(
          onPressed: _addPostForm, child: const Text('Add Post')),
      body: Column(
        children: [
          Expanded(
            child: _buildPostsList(),
          ),
        ],
      ),
    );
  }

  void _addPostForm() async {
    await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.grey[100],
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'Enter a title...',
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'Enter post content...',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 6,
                        maxLines: 10,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: 'Enter image url...'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                          onPressed: () => _addPost(
                              _titleController.text,
                              _contentController.text,
                              _imageUrlController.text),
                          child: const Text('Add Post'))
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> _addPost(String title, String content, String imageUrl) async {
    if (_titleController.text.isNotEmpty) {
      await _chatService.addPost(widget.topicID, _titleController.text,
          _contentController.text, _imageUrlController.text);
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();
  }

  Widget _buildPostsList() {
    return StreamBuilder(
        stream: _chatService.getPosts(widget.topicID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('has error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot document = snapshot.data!.docs[index];
                return PostItem(
                    document: document, likes: document['likes'] ?? []);
              });
        });
  }
}
