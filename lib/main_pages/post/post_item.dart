import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/main_pages/post/comment_button.dart';

import '../../util/post_service.dart';
import 'like_button.dart';

class PostItem extends StatefulWidget {
  final DocumentSnapshot document;
  final List<dynamic> likes;
  const PostItem({super.key, required this.document, required this.likes});

  @override
  // ignore: library_private_types_in_public_api
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
    isLiked = !isLiked;

    String topicID = widget.document.reference.parent.parent!.id;
    String postID = widget.document.id;
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .doc(postID);
    if (isLiked) {
      postRef.update({
        // adds uid to post likes
        'likes': FieldValue.arrayUnion([user.uid])
      });
    } else {
      postRef.update({
        // removes uid from post likes
        'likes': FieldValue.arrayRemove([user.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return FutureBuilder<String?>(
      future: PostService().getUserName(data['userID']),
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
                    child: Column(
                      children: [
                        Image.network(
                          data['imageURL'],
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, exception, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                        Text(
                          data['content'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
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
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostComments(
                                            post: widget,
                                            topicID: widget.document.reference
                                                .parent.parent!.id,
                                            postID: widget.document.id,
                                          )));
                            },
                            child: const Icon(Icons.chat))
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
