import 'package:get/get.dart';
import '../ui/auth_root.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/register_page.dart';
import '../ui/wallet/wallet_detail_page.dart';

class Routes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String wallet = '/wallet/:id';
  static const String profile = '/profile';
  static const String invitations = '/invitations';
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.root,
      page: () => const AuthRoot(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.wallet,
      page: () {
        final walletId = Get.parameters['id'] ?? '';
        return WalletDetailPage(walletId: walletId);
      },
      transition: Transition.rightToLeft,
    ),
  ];
}
