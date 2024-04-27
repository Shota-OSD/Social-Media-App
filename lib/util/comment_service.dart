import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/util/comment.dart';

class CommentService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment(
      String topicID, String postID, String message) async {
    final String userID = _auth.currentUser!.uid;
    final String userEmail = _auth.currentUser!.email.toString();
    final DateTime timestamp = Timestamp.now().toDate();

    Comment newMessage = Comment(
        senderID: userID,
        senderEmail: userEmail,
        postID: postID,
        message: message,
        timestamp: timestamp);

    //adding message to firestore
    await _firestore
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getComments(String topicID, String postID) {
    return _firestore
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
