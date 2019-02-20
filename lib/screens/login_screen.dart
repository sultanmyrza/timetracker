import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Welcome"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          final GoogleSignInAccount googleUser = await googleSignIn.signIn();

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          final AuthCredential credential = GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          FirebaseAuth firebaseAuthInstance = firebaseAuth;
          final FirebaseUser firebaseUser =
              await firebaseAuthInstance.signInWithCredential(credential);

          print("signed in " + firebaseUser.displayName);
        },
        icon: Icon(Icons.verified_user),
        label: Text("Google sign in"),
      ),
    );
  }
}
