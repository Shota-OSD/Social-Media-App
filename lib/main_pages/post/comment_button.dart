import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Comments'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              widget.post,
              Expanded(
                child: StreamBuilder(
                  stream: _commentService.getComments(
                    widget.topicID,
                    widget.postID,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('has error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildMessageInput(),
      resizeToAvoidBottomInset: false,
    );
  }

  //comment item
  Widget _buildCommentItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderID'] == _auth.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (data['senderID'] == _auth.currentUser!.uid)
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['senderEmail'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (data['senderID'] == _auth.currentUser!.uid)
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['message'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format((data['timestamp'] as Timestamp).toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // message input
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8),
          Material(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: addComment,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
