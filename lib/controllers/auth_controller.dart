import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  Location location = Location();
  LocationData lData;
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Rx<User> _firebaseUser = Rx<User>();
  LocationData locationDataAsync;
  Rx<LocationData> _locationData = Rx<LocationData>();
  User get user => _firebaseUser?.value;
  LocationData get locationData => _locationData?.value;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  @override
  void onInit() {
    print('onInit');
    location.getLocation();
   /*  _firebaseUser.bindStream(_auth.authStateChanges());
    _locationData.bindStream(location.onLocationChanged);
    _locationData.listen((location) {
      print('location no authcontroller: $location');
    });
    initDistancia(); */
    super.onInit();
    // initializeFCM();
  }

   @override
  void onReady() {
    super.onReady();
    print("onReady()");
  }

  initDistancia() async {
    print('initDistancia authcontroller');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationDataAsync = await location.getLocation();
    print('locationData AuthController: $locationData');
    update();
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

  Future<void> recarregarEstabelecimentos() async {
    await databaseService.inicializarFirebase();
    update();
  }

  Future getLocation() async {
    lData = await location.getLocation();
    update();
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
