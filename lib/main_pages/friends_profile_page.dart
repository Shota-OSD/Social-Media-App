import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsProfilePage extends StatefulWidget {
  FriendsProfilePage({super.key, required this.userID});
  final String userID;

  @override
  State<FriendsProfilePage> createState() => _FriendsProfilePage();
}

class _FriendsProfilePage extends State<FriendsProfilePage> {
  late final DocumentReference _friends;
  late final CollectionReference _CurrentUserFriends;
  String? profileImageUrl;
  late bool _isFriend;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _friends = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(widget.userID);
    _CurrentUserFriends = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(user.uid)
        .collection('friends');
    fetchImageUrl();
    _checkFriend();
  }

  Future<void> _checkFriend() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshotFromUsers =
          await FirebaseFirestore.instance
              .collection('usersCollection')
              .doc(widget.userID)
              .get();
      String email = snapshotFromUsers.data()?['email'];
      DocumentSnapshot snapshotFromFrends =
          await _CurrentUserFriends.doc(email).get();
      setState(() {
        if (snapshotFromFrends.exists) {
          _isFriend = true;
        } else {
          _isFriend = false;
        }
      });
    } catch (error) {
      print("Failed to get information URL: $error");
    }
  }

  Future<void> fetchImageUrl() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('usersCollection')
          .doc(widget.userID)
          .get();
      setState(() {
        profileImageUrl = snapshot.data()?['profileImage'];
      });
    } catch (error) {
      print("Failed to fetch image URL: $error");
    }
  }

  Future<void> _addFriend() async {
    DocumentSnapshot<Map<String, dynamic>> snapshotFromUsers =
        await FirebaseFirestore.instance
            .collection('usersCollection')
            .doc(widget.userID)
            .get();
    var friendData = snapshotFromUsers.data() as Map<String, dynamic>;
    await _CurrentUserFriends.doc(friendData['email']).set({
      "firstName": friendData['firstName'],
      "lastName": friendData['lastName']
    });
    _checkFriend();
  }

  Future<void> _deleteFriend() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshotFromUsers =
          await FirebaseFirestore.instance
              .collection('usersCollection')
              .doc(widget.userID)
              .get();
      String email = snapshotFromUsers.data()?['email'];
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have successfully unfollowed.')));
      await _CurrentUserFriends.doc(email).delete();
      _checkFriend();
    } catch (error) {
      print("Failed to unfollow user: $error");
    }
  }

  Future<void> _confirmDeleteFriend() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Unfollow'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to unfollow this user?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Unfollow'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFriend();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: _friends.get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData) {
              return const Text('No data found');
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            var userFirstName = userData['firstName'] as String;
            var userLastName = userData['lastName'] as String;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl.toString())
                          as ImageProvider<Object>?
                      : const AssetImage('assets/images/profile_icon.png'),
                ),
                const SizedBox(height: 20),
                Text(
                  "$userFirstName $userLastName",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _isFriend ? _confirmDeleteFriend() : _addFriend();
                  },
                  child: Text(_isFriend ? 'Unfollow' : 'Follow'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
