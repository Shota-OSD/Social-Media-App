import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/util/chat_service.dart';
import 'package:intl/intl.dart';

class TopicRoom extends StatefulWidget {
  final String topicID;
  const TopicRoom({super.key, required this.topicID});

  @override
  State<TopicRoom> createState() => _TopicRoomState();
}

class _TopicRoomState extends State<TopicRoom> {
  final ChatService _chatService = ChatService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(widget.topicID),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildPostsList(),
          ),
          ElevatedButton(onPressed: _addPostForm, child: const Text('Add Post'))
        ],
      ),
    );
  }

  void _addPostForm() async {
    await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.red[50],
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
                        onPressed: () => _addPost(_titleController.text,
                            _contentController.text, _imageUrlController.text),
                        child: const Text('Add Post'))
                  ],
                ),
              ),
            ));
  }

  Future<void> _addPost(String title, String content, String imageUrl) async {
    if (_titleController.text.isNotEmpty) {
      await _chatService.addPost(widget.topicID, _titleController.text,
          _contentController.text, _imageUrlController.text);
    }
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
            return const Text('loading');
          }
          return ListView(
              children: snapshot.data!.docs
                  .map((document) => _buildPostsItem(document))
                  .toList());
        });
  }

  Widget _buildPostsItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return FutureBuilder<String?>(
      future: _chatService.getUserName(data['userID']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is resolving, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If there's an error with the future, display an error message
          return Text('Error fetching user name: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          // If no data was retrieved from the future, handle the case gracefully
          return Text('User name not found');
        } else {
          // If the future has completed successfully, display the user name
          String userName = snapshot.data!;
          DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
          String formattedDateTime =
              DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'at: $formattedDateTime',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(data['content']),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
