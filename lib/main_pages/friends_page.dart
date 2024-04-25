import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;
  @override
  State<FriendsList> createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  final TextEditingController _nameController = TextEditingController();
  late final User? user;
  late final CollectionReference _friends;

  @override
  void initState() {
    super.initState();
    user = widget.auth.currentUser;
    _friends = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(widget.auth.currentUser!.uid)
        .collection('friends');
  }

  Future<void> _addFriend() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Search by email'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text('Search'),
                onPressed: () async {
                  final String? email = _nameController.text;
                  if (email != null) {
                    // Firestoreのusersコレクションからemailでユーザーを検索する
                    var userQuery = await FirebaseFirestore.instance
                        .collection('usersCollection')
                        .where('email', isEqualTo: email)
                        .get();
                    if (userQuery.docs.isNotEmpty) {
                      // ユーザーが見つかった場合は、その情報を_friendsコレクションに追加する
                      var userData =
                          userQuery.docs.first.data() as Map<String, dynamic>;
                      await _friends.doc(email).set({
                        "firstName": userData['firstName'],
                        "lastName": userData['lastName']
                      });
                      _nameController.text = '';
                      Navigator.of(context).pop();
                    } else {
                      // ユーザーが見つからなかった場合はエラーを表示するなどの処理を行う
                      showDialog(
                        context: ctx,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('User not found!'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

// Deleteing a friend by email
  Future<void> _deleteFriend(String email) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted!')));
    await _friends.doc(email).delete();
  }

  Future<void> _confirmDeleteFriend(String email) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this friend?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFriend(email);
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
        title: const Text("Friends List"),
      ),
      body: StreamBuilder(
        stream: _friends.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        leading: const Column(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/images/profile_icon.png'),
                            ),
                          ],
                        ),
                        title: Text(documentSnapshot['firstName']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => {}),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteFriend(
                                      documentSnapshot.id)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addFriend();
        },
        backgroundColor: Colors.red[100],
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
    );
  }
}
