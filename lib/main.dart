//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudo_no_tabuleiro_app/controllers/bindings/auth_binding.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'services/database_service.dart';

String estabelecimentoId;
String tipoNotificacao;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  estabelecimentoId = message.data['estabelecimentoId'] ?? '';
  tipoNotificacao = message.data['tipo'] ?? '';
  print('estabelecimentoID backgroundHandler: ${message.data}');
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString(
      'estabelecimentoId', message.data['estabelecimentoId'] ?? '');
  await sharedPreferences.setString('tipo', message.data['tipo'] ?? '');

  print(
      "Handling a background message: ${message.messageId} setBool>>> ${sharedPreferences.getString('tipo')}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await Firebase.initializeApp();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    print('message.data> ${message.data}');
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android?.smallIcon,
              // other properties...
            ),
          ));
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int selectedTab;
  bool backgroundMessage = false;
  String estabelecimentoIdNotificacao;
  MyApp() {
    _firebaseMessaging.subscribeToTopic('sorteio');
    _firebaseMessaging.subscribeToTopic('teste');
    _firebaseMessaging.getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static onBackGroundMessage() {
    databaseService.backgroundMessage = true;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      title: 'Tudo no Tabuleiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
          future: databaseService.inicializarFirebase(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Ocorreu um erro durante a solicitação'),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return HomePage(
                selectedTab: selectedTab ?? 0,
              );
            }
            return Container(
                child: Stack(
              fit: StackFit.expand,
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
