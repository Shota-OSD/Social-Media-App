import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friends_profile_page.dart';

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
  late final CollectionReference _friendRequests;
  late String profileImageUrl;
  //List<bool> _hasimage =[];

  @override
  void initState() {
    super.initState();
    user = widget.auth.currentUser;
    _friends = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(widget.auth.currentUser!.uid)
        .collection('friends');
    _friendRequests = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(widget.auth.currentUser!.uid)
        .collection('friendRequests');
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
                child: const Text('Add to '),
                onPressed: () async {
                  final String? email = _nameController.text;
                  if (email != null) {
                    // Search for users by email from the Firestore users collection
                    var userQuery = await FirebaseFirestore.instance
                        .collection('usersCollection')
                        .where('email', isEqualTo: email)
                        .get();
                    if (userQuery.docs.isNotEmpty) {
                      // If a user is found, add the information to the _friends collection
                      var friendData =
                          userQuery.docs.first.data() as Map<String, dynamic>;
                      await _friends.doc(email).set({
                        "firstName": friendData['firstName'],
                        "lastName": friendData['lastName']
                      });
                      // Add userData to friendRequest collection
                      var userDataSnapshot = await FirebaseFirestore.instance
                          .collection('usersCollection')
                          .doc(widget.auth.currentUser!.uid)
                          .get();
                      Map<String, dynamic> userData =
                          userDataSnapshot.data() as Map<String, dynamic>;
                      // Create friendRequest collection if not exists and add userData
                      var friendRequestCollection = FirebaseFirestore.instance
                          .collection('usersCollection')
                          .doc(userQuery.docs.first.id)
                          .collection('friendRequests');
                      // Set userData to friendRequest collection
                      await friendRequestCollection.doc(userData['email']).set({
                        "firstName": userData['firstName'],
                        "lastName": userData['lastName']
                      });
                      _nameController.text = '';
                      Navigator.of(context).pop();
                    } else {
                      // If a user is not found, display an error, etc.
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

  Future<void> _approveFriend(String email) async {
    var userQuery = await FirebaseFirestore.instance
        .collection('usersCollection')
        .where('email', isEqualTo: email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      // If a user is found, add the information to the _friends collection
      var friendData = userQuery.docs.first.data() as Map<String, dynamic>;
      await _friends.doc(email).set({
        "firstName": friendData['firstName'],
        "lastName": friendData['lastName']
      });
    }
    await _friendRequests.doc(email).delete();
  }

// Deleteing a friend by email
  Future<void> _deleteFriend(String email, bool isFriend) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted!')));
    await isFriend
        ? _friends.doc(email).delete()
        : _friendRequests.doc(email).delete();
  }

  Future<void> _confirmDeleteFriend(String email, bool isFriend) async {
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
                _deleteFriend(email, isFriend);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchImageUrl(DocumentSnapshot snapshot) async {
    try {
      setState(() {
        profileImageUrl = snapshot['profileImage'];
      });
    } catch (error) {
      setState(() {
        profileImageUrl = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List"),
      ),
      body: ListView(children: [
        Container(
            height: 400,
            child: StreamBuilder(
              stream: _friends.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      var _ = fetchImageUrl(documentSnapshot);
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FriendsProfilePage(
                                      auth: widget.auth,
                                      email: documentSnapshot.id)),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  leading: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: profileImageUrl != ""
                                            ? NetworkImage(profileImageUrl)
                                                as ImageProvider<Object>?
                                            : const AssetImage(
                                                'assets/images/profile_icon.png'),
                                      ),
                                    ],
                                  ),
                                  title: Text(documentSnapshot['firstName']),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                _confirmDeleteFriend(
                                                    documentSnapshot.id, true)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                  );
                } else {
                  const Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "You have no friends.\nAdd your friends from button!",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
        const Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              " Friend Requests",
              style: TextStyle(
                  color: Color.fromARGB(255, 65, 64, 64), fontSize: 30),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
        Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.deepOrange[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: StreamBuilder(
              stream: _friendRequests.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      var _ = fetchImageUrl(documentSnapshot);
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FriendsProfilePage(
                                      auth: widget.auth,
                                      email: documentSnapshot.id)),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  leading: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: profileImageUrl != ""
                                            ? NetworkImage(profileImageUrl)
                                                as ImageProvider<Object>?
                                            : AssetImage(
                                                'assets/images/profile_icon.png'),
                                      ),
                                    ],
                                  ),
                                  title: Text(documentSnapshot['firstName']),
                                  trailing: SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                            child: const Text('Approve'),
                                            onPressed: () => {
                                                  _approveFriend(
                                                      documentSnapshot.id)
                                                }),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                _confirmDeleteFriend(
                                                    documentSnapshot.id,
                                                    false)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
      ]),
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
