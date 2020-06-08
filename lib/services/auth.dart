import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letschat/helper/HelperFunctions.dart';
import 'package:letschat/screens/chatRoom.dart';
import 'package:letschat/screens/register.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool userIsLggedIn = false;

  handleAuth() {
    getLoggedInState();
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData && userIsLggedIn) {
            return ChatRoom();
          } else {
            return Register();
          }
        });
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value){
      userIsLggedIn = (value != null) ? value : false;
    });
  }

  //Sign out
  signOut() {
    _auth.signOut();
  }

  //SignIn
  signIn(AuthCredential authCreds) {
    _auth.signInWithCredential(authCreds);
  }

  signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
}