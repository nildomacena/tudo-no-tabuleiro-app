/* import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialize() async {
    _fcm.configure(onLaunch: (data) {
      print('onLaunch  $data');
    }, onMessage: (data) {
      print('onMessage $data');
      Get.dialog(AlertDialog(
        title: Text(
          'Tem sorteio novo na área!',
        ),
        content: Text(data['notification']['body']),
        actions: [
          TextButton(
              onPressed: () {
                Get.offAll(HomePage(/*  */
                  selectedTab: 2,
                ));
              },
              child: Text('IR PARA SORTEIOS')),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('CANCELAR')),
        ],
      ));
    }, onResume: (data) {
      print('Resume $data');
    });
  }
}
 */
