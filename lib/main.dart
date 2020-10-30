import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/bindings/auth_binding.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/gateway_notificacao/gateway_notificacao.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/app_icon', [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white)
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int selectedTab;
  bool backgroundMessage = false;
  String estabelecimentoIdNotificacao;
  MyApp() {
    _firebaseMessaging.subscribeToTopic('sorteio');
    _firebaseMessaging.configure(
        //onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (data) {
      print('onLaunch  $data');
      if (data['data']['tipo'] == 'sorteio')
        selectedTab = 2;
      else if (data['data']['key'] != null)
        estabelecimentoIdNotificacao = data['data']['key'];
    }, onMessage: (data) {
      print('onMessage $data');
      if (data['data']['tipo'] == 'sorteio')
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
      else if (data['data']['tipo'] == 'estabelecimento') {
        Get.dialog(AlertDialog(
          title: Text(
            data['notification']['title'],
          ),
          content: Text(data['notification']['body']),
          actions: [
            if (data['data']['key'] != null)
              FlatButton(
                  onPressed: () {
                    Get.to(EstabelecimentoPage(databaseService
                        .estabelecimentoById(data['data']['key'])));
                  },
                  child: Text('CONFIRA')),
            FlatButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('CANCELAR')),
          ],
        ));
      }
    }, onResume: (data) {
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
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      /* Navigator.of(context).pushName(context, '/NotificationPage', arguments: {
        id: receivedNotification.id
      }); */ // your page params. I recomend to you to pass all *receivedNotification* object
      print('receivedNotification $receivedNotification');
    });
    AwesomeNotifications().displayedStream.listen((receivedNotification) {
      /* Navigator.of(context).pushName(context, '/NotificationPage', arguments: {
        id: receivedNotification.id
      }); */ // your page params. I recomend to you to pass all *receivedNotification* object
      print('receivedNotification displayed stream $receivedNotification');
    });
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
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
              return FutureGetEstabelecimentos(
                selectedTab: selectedTab ?? 0,
                estabelecimentoIdNotificacao: estabelecimentoIdNotificacao,
              );
            }
            return Container(
                child: Stack(
              children: [
                Image.asset('assets/icon/splashscreen.png', fit: BoxFit.cover),
                Positioned(
                  bottom: 240,
                  left: Get.width * .43,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ));
          }),
    );
  }
}

class FutureGetEstabelecimentos extends StatelessWidget {
  int selectedTab;
  String estabelecimentoIdNotificacao;
  FutureGetEstabelecimentos(
      {this.selectedTab, this.estabelecimentoIdNotificacao});
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
            return HomePage(
              selectedTab: selectedTab ?? 0,
              estabelecimentoIdNotificacao: estabelecimentoIdNotificacao,
            );
          }
          return Container(
            color: Colors.green,
            height: Get.height,
            width: Get.width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  child: Image.asset('assets/icon/splashscreen.png', fit: BoxFit.cover)),
                Positioned(
                  bottom: 240,
                  left: Get.width * .45,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
