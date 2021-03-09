import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  User get user => _auth.currentUser;

  AuthService() {
    print('User authservice: ${_auth.currentUser}');
  }
  Future<User> getUser() async {
    User user;
    await Future.delayed(Duration(seconds: 1), () {
      user = _auth.currentUser;
    });
    return user;
  }

  Future<User> loginComGoogle() async {
    utilService.loadingAlert();
    GoogleSignInAccount googleSignInAccount;
    GoogleSignInAuthentication googleSignInAuthentication;
    AuthCredential authCredential;
    UserCredential userCredential;
    try {
      googleSignInAccount = await _googleSignIn.signIn();
      googleSignInAuthentication = await googleSignInAccount.authentication;
      authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      userCredential = await _auth.signInWithCredential(authCredential);
      databaseService.checkUserBDInfo(userCredential.user);
    } catch (e) {
      print('Ocorreu um erro durante o login: $e');
    }
    Get.back();
    return _auth.currentUser;
  }

  logout() {
    _auth.signOut();
  }
}

AuthService authService = AuthService();
