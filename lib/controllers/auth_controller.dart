import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Rx<User> _firebaseUser = Rx<User>();

  User get user => _firebaseUser?.value;

  @override
  void onInit() {
    print('onInit');
    _firebaseUser.bindStream(_auth.authStateChanges());
   // initializeFCM();
  }

  /* Future initializeFCM() async {
    _firebaseMessaging.configure(onLaunch: (data) {
      print('onLaunch  $data');
    }, onMessage: (data) {
      print('onMessage $data');
      Get.dialog(AlertDialog(
        title: Text(
          'Tem sorteio novo na área!',
        ),
        content: Text(data['notification']['body']),
        actions: [
          FlatButton(
              onPressed: () {
                Get.offAll(HomePage(
                  selectedTab: 2,
                ));
              },
              child: Text('IR PARA SORTEIOS')),
          FlatButton(
              onPressed: () {
                Get.back();
              },
              child: Text('CANCELAR')),
        ],
      ));
    }, onResume: (data) {
      print('Resume $data');
    });
  } */

  Future<void> login() async {
    print('login');
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
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
