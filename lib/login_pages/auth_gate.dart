import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/main_pages/home_screen.dart';
import '../util/index.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            onSignIn: (email, password) {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password);
            },
            onSignUp:
                (email, password, firstName, lastName, dob, selectedGender) {
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password)
                  .then((registerUser) => {
                        FirebaseFirestore.instance
                            .collection('usersCollection')
                            .doc(registerUser.user!.uid)
                            .set({
                          'uid': registerUser.user!.uid,
                          'email': email,
                          'firstName': firstName,
                          'lastName': lastName,
                          'dob': dob,
                          'gender': selectedGender,
                          'created': Timestamp.now()
                        })
                      });
            },
          );
        }

        return const AppTabs();
      },
    );
  }
}
