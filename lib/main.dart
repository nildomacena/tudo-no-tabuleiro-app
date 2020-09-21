import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/bindings/auth_binding.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool backgroundMessage = false;
  MyApp() {
    _firebaseMessaging.subscribeToTopic('sorteio');
    _firebaseMessaging.configure(
        //onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (data) {
          print('onLaunch  $data');
        },
        onMessage: (data) {
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
        },
        onResume: (data) {
          print('Resume $data');
        });
  }

  static onBackGroundMessage() {
    databaseService.backgroundMessage = true;
  }

  static Future myBackgroundMessageHandler(Map<String, dynamic> message) {
    print('myBackgroundMessageHandler');
    if (message.containsKey('data')) {
// Handle data message
      final dynamic data = message['data'];
      print('myBackgroundMessageHandler $data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AuthBinding(),
      title: 'Tudo no Tabuleiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Ocorreu um erro durante a solicitação'),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureGetEstabelecimentos();
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class FutureGetEstabelecimentos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseService.carregarEstabelecimentos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Ocorreu um erro durante a solicitação'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data) {
            return HomePage();
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
