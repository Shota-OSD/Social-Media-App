import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/util/post.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPost(
      String topicID, String title, String content, String? imageURL) async {
    final String userID = _auth.currentUser!.uid;
    final DateTime timestamp = Timestamp.now().toDate();

    Post newPost = Post(
        userID: userID,
        topicID: topicID,
        title: title,
        content: content,
        imageURL: imageURL,
        timestamp: timestamp);

    //adding post to firestore
    await _firestore
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .add(newPost.toMap());
  }

  Stream<QuerySnapshot> getPosts(String topicID) {
    return _firestore
        .collection('topics')
        .doc(topicID)
        .collection('posts')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<String?> getUserName(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('usersCollection')
              .where('uid', isEqualTo: userId)
              .get();

      if (querySnapshot.size > 0) {
        String? userName = querySnapshot.docs[0].get('firstName') +
            ' ' +
            querySnapshot.docs[0].get('lastName');
        return userName;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user name: $e');
      return null;
    }
  }
}
