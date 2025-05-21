import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/wallet_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(), fenix: true);
  }
}
