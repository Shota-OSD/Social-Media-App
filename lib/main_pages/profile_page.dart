import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../util/index.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late final DocumentReference _user;
  File? _imageFile;
  String? profileImageUrl;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(widget.auth.currentUser!.uid);
    fetchImageUrl();
  }

  Future logOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthGate(),
    ));
  }

  Future<void> fetchImageUrl() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('usersCollection')
          .doc(widget.auth.currentUser!.uid)
          .get();
      setState(() {
        profileImageUrl = snapshot.data()?['profileImage'];
      });
    } catch (error) {
      print("Failed to fetch image URL: $error");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final storage = FirebaseStorage.instance;
    final Reference storageRef =
        storage.ref().child('images/${DateTime.now()}.png');
    await storageRef.putFile(_imageFile!);

    final imageUrl = await storageRef.getDownloadURL();

    Map<String, dynamic> newData = {
      'profileImage': imageUrl,
    };
    try {
      await _user.update(newData);
      print("Document updated successfully!");
    } catch (error) {
      print("Failed to update document: $error");
    }

    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _editProfile(String userFirstName, String userLastName) async {
    _firstNameController.text = userFirstName;
    _lastNameController.text = userLastName;
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
                    ElevatedButton(
                        onPressed: () {
                          _pickImage();
                        },
                        child: const Text('Select Phote')),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: Text('Edit'),
                      onPressed: () async {
                        final String? firstName = _firstNameController.text;
                        final String? lastName = _lastNameController.text;
                        await _uploadImage();
                        await fetchImageUrl();
                        if (firstName != null) {
                          await _user.update({
                            "firstName": firstName,
                          });
                          _firstNameController.text = '';
                        }
                        if (lastName != null) {
                          await _user.update({"lastName": lastName});
                          _lastNameController.text = '';
                        }
                        Navigator.of(context).pop();
                      },
                    )
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: _user.get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (!snapshot.hasData) {
              return Text('No data found');
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
                SizedBox(height: 20),
                Text(
                  "${userFirstName} ${userLastName}",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _editProfile(userFirstName, userLastName);
                      },
                      child: const Text('Edit Profile'),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        logOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
