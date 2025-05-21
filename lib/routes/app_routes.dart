import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ui/home/home_page.dart';
import '../ui/wallet/wallet_detail_page.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String wallet = '/wallet/:id';
  static const String addTransaction = '/wallet/:id/add-transaction';
  static const String profile = '/profile';
  static const String invitations = '/invitations';
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
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
