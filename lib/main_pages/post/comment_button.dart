import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/util/comment_service.dart';

class PostComments extends StatefulWidget {
  final Widget post;
  final String postID;
  final String topicID;
  const PostComments(
      {super.key,
      required this.post,
      required this.postID,
      required this.topicID});

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  final TextEditingController _messageController = TextEditingController();
  final CommentService _commentService = CommentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void addComment() async {
    if (_messageController.text.isNotEmpty) {
      await _commentService.addComment(
          widget.topicID, widget.postID, _messageController.text);
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      widget.post,
                      StreamBuilder(
                        stream: _commentService.getComments(
                          widget.topicID,
                          widget.postID,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('has error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('...loading');
                          }
                          return ListView(
                            shrinkWrap: true,
                            children: snapshot.data!.docs
                                .map((document) => _buildCommentItem(document))
                                .toList(),
                          );
                        },
                      ),
                      _buildMessageInput()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //message item
  Widget _buildCommentItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderID'] == _auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var messageColor = (data['senderID'] == _auth.currentUser!.uid)
        ? Colors.blueAccent[200]
        : Colors.grey[500];
    // Get the timestamp from Firestore data as a DateTime object
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

    // Format the DateTime into a desired string representation
    String formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: messageColor,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  data['senderEmail'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'at: ' + formattedDateTime,
                  style: TextStyle(
                      color: Colors.grey[400], fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(data['message']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          obscureText: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.all(20),
          ),
        )),
        Container(
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: Colors.blue[100]),
          child: IconButton(
            onPressed: addComment,
            icon: const Icon(
              Icons.arrow_upward,
              size: 30,
            ),
          ),
        )
      ],
    );
  }
}
