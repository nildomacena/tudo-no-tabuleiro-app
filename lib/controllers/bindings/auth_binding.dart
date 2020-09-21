import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';
import 'package:tudo_no_tabuleiro_app/controllers/notification_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('authBinding');
    Get.lazyPut<AuthController>(() => AuthController());
   // Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
