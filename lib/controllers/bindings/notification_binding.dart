import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    print('authBinding');
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
