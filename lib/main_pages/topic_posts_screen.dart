import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/main_pages/components/like_button.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    } else {
      appBarColor = Colors.lightGreenAccent;
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

class PostItem extends StatefulWidget {
  final DocumentSnapshot document;
  final List<dynamic> likes;
  PostItem({required this.document, required this.likes});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(user.uid);
  }

  void _likePost() {
    print('tapped');
    setState(() {
      isLiked = !isLiked;
    });

    String topicID = widget.document.reference.parent.parent!.id;
    String postID = widget.document.id;
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .doc(postID);
    if (isLiked) {
      postRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    } else {
      postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return FutureBuilder<String?>(
      future: ChatService().getUserName(data['userID']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching user name: ${snapshot.error}');
        } else {
          String userName = snapshot.data!;
          DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
          String formattedDateTime =
              DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          // Add user avatar here if available
                          child: Text(
                            userName[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDateTime,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      data['content'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            LikeButton(
                                isLiked: isLiked,
                                onTap: () {
                                  _likePost();
                                }),
                            Text(widget.likes.length.toString())
                          ],
                        ),
                        GestureDetector(child: Icon(Icons.chat))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
